class RoundRobinSamplerService
  def initialize(subgroup, current_user_name = nil)
    @subgroup = subgroup
    @current_user_name = current_user_name
  end

  def sample
    # Filtrar solo los participantes disponibles
    participants = @subgroup.participants.where(available: true)
    return nil if participants.empty?

    # Encontrar el valor mínimo de conteo entre los participantes disponibles
    min_count = participants.minimum(:count)

    # Seleccionar todos los participantes disponibles con el conteo mínimo
    candidates = participants.where(count: min_count)

    # Filtrar el usuario actual si se proporcionó
    if @current_user_name.present?
      candidates = candidates.where.not(name: @current_user_name)
      # Si no quedan candidatos después del filtrado, seleccionar entre todos los disponibles
      if candidates.empty?
        candidates = participants.where.not(name: @current_user_name)
        # Si aún no hay candidatos disponibles, usamos todos
        candidates = participants if candidates.empty?
      end
    end

    # Seleccionar aleatoriamente uno de los candidatos
    selected = candidates.sample

    # Incrementar el contador del participante seleccionado
    selected.update!(count: selected.count + 1) if selected

    selected
  end
end
