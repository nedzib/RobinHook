# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_16_202037) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "participants", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "round_id"
    t.bigint "subgroup_id"
    t.integer "count", default: 0
    t.boolean "available", default: true
    t.string "google_user_id"
    t.index ["round_id"], name: "index_participants_on_round_id"
    t.index ["subgroup_id"], name: "index_participants_on_subgroup_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.string "hash_id"
    t.string "name"
    t.string "web_hook"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_rounds_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.string "channel", null: false
    t.text "payload", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "channel_hash", default: "", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "subgroups", force: :cascade do |t|
    t.string "name"
    t.bigint "round_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["round_id"], name: "index_subgroups_on_round_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "participants", "rounds"
  add_foreign_key "participants", "subgroups"
  add_foreign_key "rounds", "users"
  add_foreign_key "subgroups", "rounds"
end
