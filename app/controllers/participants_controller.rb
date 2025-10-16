class ParticipantsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :update ]
  before_action :set_round
  before_action :set_participant, only: [ :update, :destroy, :edit ]

  def edit
    # La vista `edit.html.erb` será renderizada
  end

  def create
    @participant = @round.participants.new(participant_params)

    if @participant.save
      redirect_to round_path(@round), notice: "Participante agregado exitosamente."
    else
      redirect_to round_path(@round), alert: "Error al agregar participante."
    end
  end

  def update
    # Determinar si la solicitud viene de la vista pública
    is_public_view = params[:public_view] == "true"

    # Determinar la URL de redirección
    redirect_url = if is_public_view
      rounds_public_path(hash_id: @round.hash_id)
    else
      round_path(@round)
    end

    if params[:participant].present?
      if @participant.update(participant_params)
        redirect_to round_path(@round), notice: "Participante actualizado exitosamente."
      else
        render :edit
      end
    elsif params[:increment].present?
      @participant.update!(count: @participant.count + 1)
      respond_to do |format|
        format.turbo_stream { head :ok } # recibe el broadcast
        format.html { redirect_to redirect_url, notice: "Contador actualizado." }
      end
    elsif params[:decrement].present? && @participant.count > 0
      @participant.update!(count: @participant.count - 1)
      respond_to do |format|
        format.turbo_stream { head :ok } # recibe el broadcast
        format.html { redirect_to redirect_url, notice: "Contador actualizado." }
      end
    elsif params[:available].present?
      # Actualizar disponibilidad
      available = params[:available] == "true"
      old_available = @participant.available

      @participant.update(available: available)

      # Si el participante pasa de no disponible a disponible, ajustar su conteo
      if !old_available && available
        adjust_participant_count_on_return(@participant)
        status_message = "Participante marcado como disponible y conteo ajustado."
      else
        status_message = available ? "Participante marcado como disponible." : "Participante marcado como no disponible."
      end

      redirect_to redirect_url, notice: status_message
    elsif params[:subgroup_id].present?
      # Mover a un subgrupo
      if params[:subgroup_id] == "0"
        @participant.update(subgroup_id: nil, round_id: @round.id)
        redirect_to redirect_url, notice: "Participante movido a la ronda principal."
      else
        subgroup = @round.subgroups.find_by(id: params[:subgroup_id])
        if subgroup
          @participant.update(subgroup_id: subgroup.id, round_id: nil)
          redirect_to redirect_url, notice: "Participante movido al subgrupo."
        else
          redirect_to redirect_url, alert: "Subgrupo no encontrado."
        end
      end
    else
      redirect_to redirect_url
    end
  end

  def destroy
    @participant.destroy

    redirect_to round_path(@round), notice: "Participante eliminado exitosamente."
  end

  private

  def set_round
    if params[:round_id]
      @round = Round.find(params[:round_id])
    elsif params[:id]
      @participant = Participant.find(params[:id])
      @round = @participant.round if @participant
    end

    unless @round
      # Manejar el caso en que la ronda no se encuentra
      redirect_to rounds_path, alert: "Ronda no encontrada."
    end
  end

  def set_participant
    # Buscar el participante tanto en la ronda principal como en los subgrupos
    @participant = Participant.find_by(id: params[:id])

    unless @participant
      redirect_to round_path(@round), alert: "Participante no encontrado."
    end
  end

  def participant_params
    params.require(:participant).permit(:name, :available, :google_user_id)
  end

  # Ajusta el conteo de un participante cuando vuelve a estar disponible
  def adjust_participant_count_on_return(participant)
    # Determinar si el participante está en un subgrupo o en la ronda principal
    if participant.subgroup_id.present?
      # Participante está en un subgrupo
      available_participants = Participant.where(subgroup_id: participant.subgroup_id, available: true)
                                         .where.not(id: participant.id)
    else
      # Participante está en la ronda principal
      available_participants = @round.participants.where(available: true)
                                    .where.not(id: participant.id)
    end

    if available_participants.any?
      # Obtener el conteo más bajo de los participantes disponibles
      min_count = available_participants.minimum(:count)

      # Asignar ese conteo al participante que regresa
      participant.update(count: min_count)
    else
      # Si no hay otros participantes disponibles, mantener el conteo actual
      # o ponerlo en 0 si se prefiere
      participant.update(count: 0)
    end
  end
end
