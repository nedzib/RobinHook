class AddChannelHashToSolidCableMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :solid_cable_messages, :channel_hash, :string, null: false, default: ""

    add_index :solid_cable_messages, :channel_hash
    add_index :solid_cable_messages, :created_at
  end
end
