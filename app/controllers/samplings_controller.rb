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
            { role: "user", content: "crea el mensaje" }
          ],
          temperature: 0.7
        }
      ).dig("choices", 0, "message", "content")
      rescue
        response = "#{@participant.name} ha sido seleccionadx para revisar el PR: <url>"
      end

      if params[:pr_url].present? && @round.web_hook.present?
        message = response.gsub("<user>", @participant.name)
        notifier = WebhookNotificationService.new(@round.web_hook)
        notifier.send_notification(message, source, params[:pr_url])
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
      "programación", "diseño", "ciencia ficción", "historia", "música", "cine",
      "literatura", "videojuegos", "mitología", "Los Simpson", "tecnología",
      "Star Wars", "inteligencia artificial", "filosofía", "viajes", "naturaleza",
      "astronomía", "astrología", "matemáticas", "cómics", "gastronomía",
      "arte", "anime/manga", "cultura pop", "memes"
    ]

    "Genera una frase corta, ingeniosa y graciosa para notificar que una persona ha sido asignada a revisar un Pull Request.
    Reglas:
    - Escribe siempre en español.
    - Incluye exactamente una vez el texto <user> (luego se reemplazará por el nombre del asignado).
    - No menciones familiares ni relaciones personales.
    - Debe caber en una sola línea.
    - No empieces con 'Este PR' ni con frases genéricas como 'Prepárate'.
    - Incorpora uno o dos emojis relevantes.
    - Inspírate en la temática: #{tematicas.sample}.
    - Mantén un tono humorístico, ágil y diferente en cada frase (sin repetición de estructuras)."
  end
end
