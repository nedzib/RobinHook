class GlobalRoundRobinSamplerService
  def initialize(round)
    @round = round
  end
  
  def sample
    # Obtener todos los participantes disponibles (directos e indirectos)
    participants = get_all_available_participants
    return nil if participants.empty?
    
    # Encontrar el valor mínimo de conteo entre los participantes disponibles
    min_count = participants.minimum(:count)
    
    # Seleccionar todos los participantes disponibles con el conteo mínimo
    candidates = participants.where(count: min_count)
    
    # Seleccionar aleatoriamente uno de los candidatos
    selected = candidates.sample
    
    # Incrementar el contador del participante seleccionado
    selected.increment!(:count) if selected
    
    selected
  end
  
  private
  
  def get_all_available_participants
    # Participantes directos de la ronda que estén disponibles
    direct_participants = @round.participants.where(available: true)
    
    # Participantes disponibles de los subgrupos
    subgroup_ids = @round.subgroups.pluck(:id)
    subgroup_participants = Participant.where(subgroup_id: subgroup_ids, available: true)
    
    # Combinar ambos conjuntos de participantes disponibles
    Participant.where(id: direct_participants.pluck(:id) + subgroup_participants.pluck(:id))
  end
end
