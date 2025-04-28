class AddSubgroupRefAndCountToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_reference :participants, :subgroup, null: true, foreign_key: true
    add_column :participants, :count, :integer, default: 0
  end
end
