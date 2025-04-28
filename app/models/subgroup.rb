class Subgroup < ApplicationRecord
  belongs_to :round
  has_many :participants, dependent: :nullify
  
  validates :name, presence: true
end
