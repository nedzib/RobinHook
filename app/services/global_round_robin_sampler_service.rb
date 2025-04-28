class GlobalRoundRobinSamplerService
  def initialize(round)
    @round = round
  end
  
  def sample
    # Obtener todos los participantes (directos e indirectos)
    participants = get_all_participants
    return nil if participants.empty?
    
    # Encontrar el valor mínimo de conteo
    min_count = participants.minimum(:count)
    
    # Seleccionar todos los participantes con el conteo mínimo
    candidates = participants.where(count: min_count)
    
    # Seleccionar aleatoriamente uno de los candidatos
    selected = candidates.sample
    
    # Incrementar el contador del participante seleccionado
    selected.increment!(:count)
    
    selected
  end
  
  private
  
  def get_all_participants
    # Participantes directos de la ronda
    direct_participants = @round.participants
    
    # Participantes de los subgrupos
    subgroup_ids = @round.subgroups.pluck(:id)
    subgroup_participants = Participant.where(subgroup_id: subgroup_ids)
    
    # Combinar ambos conjuntos de participantes
    Participant.where(id: direct_participants.pluck(:id) + subgroup_participants.pluck(:id))
  end
end
