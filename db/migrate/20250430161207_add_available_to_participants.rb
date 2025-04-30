class AddAvailableToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :available, :boolean, default: true
  end
end
