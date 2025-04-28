class AddRoundIdToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_reference :participants, :round, null: true, foreign_key: true
  end
end
