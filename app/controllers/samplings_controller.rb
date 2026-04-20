class SamplingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create, :public_create ]
  skip_forgery_protection only: [ :public_create ]
  before_action :set_round, only: [ :create ]
  before_action :set_subgroup, only: [ :create ], if: -> { params[:subgroup_id].present? }

  def create
    current_user_name = params[:current_user_name]
    @participant, source = sample_participant(current_user_name)
    set_sampling_flash(source, params[:pr_url])

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

  def public_create
    @round = Round.find_by!(hash_id: params[:hash_id])
    @participant, source = sample_participant(normalized_public_name)

    if @participant
      send_notification_if_needed(source, params[:url])
      render plain: @participant.name
    else
      render plain: "No hay participantes disponibles.", status: :unprocessable_entity
    end
  end

  private

  def set_round
    @round = Round.find(params[:round_id])
  end

  def set_subgroup
    @subgroup = @round.subgroups.find(params[:subgroup_id])
  end

  def sample_participant(current_user_name)
    if @subgroup
      sampler = RoundRobinSamplerService.new(@subgroup, current_user_name)
      [ sampler.sample, @subgroup.name.capitalize ]
    else
      sampler = GlobalRoundRobinSamplerService.new(@round, current_user_name)
      [ sampler.sample, "Global" ]
    end
  end

  def set_sampling_flash(source, pr_url)
    if @participant
      if send_notification_if_needed(source, pr_url)
        flash[:notice] = "#{@participant.name} ha sido seleccionado y se ha enviado la notificación."
      else
        flash[:notice] = "#{@participant.name} ha sido seleccionado."
      end
    else
      flash[:alert] = "No hay participantes disponibles."
    end
  end

  def send_notification_if_needed(source, pr_url)
    return false unless @participant && pr_url.present? && @round.web_hook.present?

    message = generated_message.gsub("<user>", @participant.name + "!")
    notifier = WebhookNotificationService.new(@round.web_hook)
    notifier.send_notification(message, source, pr_url)
  end

  def generated_message
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAPI_ACCESS_TOKEN"))

    client.chat(
      parameters: {
        model: "gpt-4.1-nano",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: "crea el mensaje" }
        ],
        temperature: 0.7
      }
    ).dig("choices", 0, "message", "content")
  rescue
    "#{@participant.name}! ha sido seleccionadx para revisar el PR: <url>"
  end

  def normalized_public_name
    params[:me].to_s.tr("_", " ")
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
