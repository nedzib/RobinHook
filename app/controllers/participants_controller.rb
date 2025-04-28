class ParticipantsController < ApplicationController
  before_action :set_round
  before_action :set_participant, only: [:update, :destroy]
  
  def create
    @participant = @round.participants.new(participant_params)
    
    if @participant.save
      redirect_to round_path(@round), notice: 'Participante agregado exitosamente.'
    else
      redirect_to round_path(@round), alert: 'Error al agregar participante.'
    end
  end
  
  def update
    if params[:increment].present?
      @participant.increment!(:count)
      redirect_to round_path(@round), notice: 'Contador incrementado.'
    elsif params[:decrement].present? && @participant.count > 0
      @participant.decrement!(:count)
      redirect_to round_path(@round), notice: 'Contador decrementado.'
    elsif params[:subgroup_id].present?
      # Mover a un subgrupo
      if params[:subgroup_id] == "0"
        @participant.update(subgroup_id: nil, round_id: @round.id)
        redirect_to round_path(@round), notice: 'Participante movido a la ronda principal.'
      else
        subgroup = @round.subgroups.find_by(id: params[:subgroup_id])
        if subgroup
          @participant.update(subgroup_id: subgroup.id, round_id: nil)
          redirect_to round_path(@round), notice: 'Participante movido al subgrupo.'
        else
          redirect_to round_path(@round), alert: 'Subgrupo no encontrado.'
        end
      end
    else
      redirect_to round_path(@round)
    end
  end
  
  def destroy
    @participant.destroy
    
    redirect_to round_path(@round), notice: 'Participante eliminado exitosamente.'
  end
  
  private
  
  def set_round
    @round = Round.find(params[:round_id])
  end
  
  def set_participant
    # Buscar el participante tanto en la ronda principal como en los subgrupos
    @participant = Participant.where(id: params[:id]).where('round_id = ? OR subgroup_id IN (?)', @round.id, @round.subgroups.pluck(:id)).first
    
    unless @participant
      redirect_to round_path(@round), alert: 'Participante no encontrado.'
    end
  end
  
  def participant_params
    params.require(:participant).permit(:name)
  end
end
