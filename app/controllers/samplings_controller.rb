class SamplingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]
  before_action :set_round
  before_action :set_subgroup, only: [ :create ], if: -> { params[:subgroup_id].present? }

  def create
    # Obtener el nombre del usuario actual desde el parámetro
    current_user_name = params[:current_user_name]

    if @subgroup
      # Muestreo por equipo
      @sampler = RoundRobinSamplerService.new(@subgroup, current_user_name)
      @participant = @sampler.sample
      source = @subgroup.name.capitalize
    else
      # Muestreo global
      @sampler = GlobalRoundRobinSamplerService.new(@round, current_user_name)
      @participant = @sampler.sample
      source = "Global"
    end

    if @participant
      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAPI_ACCESS_TOKEN"))

      begin
      response = client.chat(
        parameters: {
         model: "gpt-4.1-nano", # Required.
          messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: "NAME: #{@participant.name}" }
          ],
          temperature: 0.7
        }
      ).dig("choices", 0, "message", "content")
      rescue
        response = "#{@participant.name} ha sido seleccionadx para revisar el PR: <url>"
      end

      if params[:pr_url].present? && @round.web_hook.present?
        message = "#{source} | #{response.gsub("<url>", params[:pr_url])}"
        notifier = WebhookNotificationService.new(@round.web_hook)
        notifier.send_notification(message)
        flash[:notice] = "#{@participant.name} ha sido seleccionado y se ha enviado la notificación."
      else
        flash[:notice] = "#{@participant.name} ha sido seleccionado."
      end
    else
      flash[:alert] = "No hay participantes disponibles."
    end

    respond_to do |format|
      format.turbo_stream { head :ok } # recibe el broadcast
      format.html do
        # Determinar si la solicitud viene de la vista pública
        is_public_view = params[:public_view] == "true"

        # Redirigir a la vista pública o privada según corresponda
        if is_public_view
          redirect_to rounds_public_path(hash_id: @round.hash_id)
        else
          redirect_to round_path(@round)
        end
      end
      format.js
    end
  end

  private

  def set_round
    @round = Round.find(params[:round_id])
  end

  def set_subgroup
    @subgroup = @round.subgroups.find(params[:subgroup_id])
  end

  def system_prompt
    tematicas = [
      "programación",
      "diseño",
      "ciencia ficción",
      "historia",
      "música",
      "cine",
      "literatura",
      "videojuegos",
      "mitologia",
      "los simpson",
      "tecnología",
      "star wars",
      "inteligencia artificial",
      "filosofía",
      "viajes",
      "naturaleza",
      "astronomía",
      "astrologia",
      "matemáticas",
      "cómics",
      "gastronomía",
      "arte",
      "tecnología",
      "anime/manga",
      "cultura pop",
      "memes"
    ]
    "Quiero que generes un mensaje corto,
     para notificar que una persona ha sido asignada a revisar un Pull Request. Reglas:
       - Responde siempre en español.
       - Siempre menciona el nombre de la persona al inicio (ejemplo: “Valen, …”).
       - Incluye al final la referencia al PR con 👉 <url>.
       - No uses referencias a familiares.
       - El mensaje debe caber en una sola línea.
       - No inicies el chiste con “este PR” incorpora la existencia del PR en la frase.
       - Inicia los chistes siempre de forma distinta, evita usar siempre al inicio 'preparate', o similares
       - El mensaje debe tener rima consonante incorpora emojis.
       - Usa obligatoriamente alguna tematica #{tematicas.sample}."
  end
end
