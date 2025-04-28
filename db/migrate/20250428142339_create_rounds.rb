class CreateRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :rounds do |t|
      t.string :hash_id
      t.string :name
      t.string :web_hook
      t.references :user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
