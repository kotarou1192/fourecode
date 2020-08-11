# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_11_145804) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "master_sessions", force: :cascade do |t|
    t.string "user_id"
    t.string "token_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "onetime_sessions", force: :cascade do |t|
    t.string "user_id"
    t.string "token_digest"
    t.bigint "master_session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["master_session_id"], name: "index_onetime_sessions_on_master_session_id"
  end

  create_table "users", id: :string, limit: 36, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "nickname"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated"
    t.datetime "activated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "icon"
    t.string "explanation"
  end

  add_foreign_key "master_sessions", "users"
  add_foreign_key "onetime_sessions", "master_sessions"
  add_foreign_key "onetime_sessions", "users"
end
