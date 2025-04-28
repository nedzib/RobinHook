class Participant < ApplicationRecord
  belongs_to :round, optional: true
  belongs_to :subgroup, optional: true
  
  validates :name, presence: true
  validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # Validación para asegurar que el participante pertenezca a una ronda o a un subgrupo
  validate :belongs_to_round_or_subgroup
  
  private
  
  def belongs_to_round_or_subgroup
    if round_id.blank? && subgroup_id.blank?
      errors.add(:base, "El participante debe pertenecer a una ronda o a un subgrupo")
    end
  end
end
