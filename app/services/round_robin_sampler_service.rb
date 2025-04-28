class RoundRobinSamplerService
  def initialize(subgroup)
    @subgroup = subgroup
  end
  
  def sample
    participants = @subgroup.participants
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
end
