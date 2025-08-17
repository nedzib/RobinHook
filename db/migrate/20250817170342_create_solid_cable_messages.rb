class CreateSolidCableMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_cable_messages do |t|
      t.string :channel, null: false
      t.text :payload, null: false
      t.datetime :created_at, precision: nil, null: false
    end

    add_index :solid_cable_messages, :channel
  end
end
