class RoundRobinSamplerService
  def initialize(subgroup)
    @subgroup = subgroup
  end
  
  def sample
    # Filtrar solo los participantes disponibles
    participants = @subgroup.participants.where(available: true)
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
end
