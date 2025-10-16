class AddGoogleUserIdToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :google_user_id, :string
  end
end
