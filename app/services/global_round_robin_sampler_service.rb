class GlobalRoundRobinSamplerService
  def initialize(round, current_user_name = nil)
    @round = round
    @current_user_name = current_user_name
  end

  def sample
    # Obtener todos los participantes disponibles (directos e indirectos)
    participants = get_all_available_participants
    return nil if participants.empty?

    # Encontrar el valor mínimo de conteo entre los participantes disponibles
    min_count = participants.minimum(:count)

    # Seleccionar todos los participantes disponibles con el conteo mínimo
    candidates = participants.where(count: min_count)

    # Filtrar el usuario actual si se proporcionó
    if @current_user_name.present?
      candidates = exclude_current_user(candidates)
      # Si no quedan candidatos después del filtrado, seleccionar entre todos los disponibles
      if candidates.empty?
        candidates = exclude_current_user(participants)
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

  private

  def exclude_current_user(scope)
    scope.where("LOWER(name) <> ?", @current_user_name.downcase)
  end

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
