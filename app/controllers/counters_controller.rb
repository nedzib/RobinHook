class CountersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_round
  
  def reset
    # Obtener todos los participantes directos de la ronda
    direct_participants = @round.participants
    
    # Obtener todos los participantes de los subgrupos
    subgroup_ids = @round.subgroups.pluck(:id)
    subgroup_participants = Participant.where(subgroup_id: subgroup_ids)
    
    # Combinar ambos conjuntos de participantes
    all_participants = Participant.where(id: direct_participants.pluck(:id) + subgroup_participants.pluck(:id))
    
    # Resetear el contador de todos los participantes
    all_participants.update_all(count: 0)
    
    redirect_to round_path(@round), notice: "Se han reseteado los contadores de todos los participantes."
  end
  
  private
  
  def set_round
    @round = Round.find(params[:round_id])
  end
end
