class Participant < ApplicationRecord
  belongs_to :round, optional: true
  belongs_to :subgroup, optional: true

  validates :name, presence: true
  validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Validación para asegurar que el participante pertenezca a una ronda o a un subgrupo
  validate :belongs_to_round_or_subgroup

  after_update :broadcast_counter, if: -> { saved_changes.key?("count") }
  after_update :broadcast_available, if: -> { saved_changes.key?("available") }

  private

  def belongs_to_round_or_subgroup
    if round_id.blank? && subgroup_id.blank?
      errors.add(:base, "El participante debe pertenecer a una ronda o a un subgrupo")
    end
  end

  def broadcast_counter
    Rails.logger.info ">>> Broadcasting participant #{id} (count=#{count})"
    broadcast_replace_to(
      "count",
      target: "#{self.id}_count",
      partial: "round/count",
      locals: { participant: self }
    )
  end

  def broadcast_available
    Rails.logger.info ">>> Broadcasting participant #{id} (available=#{available})"
    broadcast_replace_to(
      "count",
      target: "#{self.id}_available",
      partial: "round/available",
      locals: { participant: self }
    )
  end
end
