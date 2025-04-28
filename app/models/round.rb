class Round < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :subgroups, dependent: :destroy
  
  validates :name, presence: true
  
  # Validación opcional para el webhook (si se proporciona, debe ser una URL válida)
  validates :web_hook, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "debe ser una URL válida" }, allow_blank: true
  
  before_create :generate_hash_id
  
  # Método para obtener todos los participantes (directos e indirectos a través de subgrupos)
  def all_participants
    direct_participants = participants
    subgroup_participants = Participant.where(subgroup_id: subgroups.pluck(:id))
    
    direct_participants.or(subgroup_participants)
  end
  
  private
  
  def generate_hash_id
    self.hash_id = SecureRandom.hex(6) if hash_id.blank?
  end
end
