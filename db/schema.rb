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

ActiveRecord::Schema.define(version: 2020_09_04_004231) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asked_users", force: :cascade do |t|
    t.string "user_id"
    t.bigint "post_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_asked_users_on_post_id"
  end

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

  create_table "password_reset_sessions", force: :cascade do |t|
    t.string "user_id"
    t.string "token_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.integer "bestanswer_reward"
    t.string "source_url"
    t.string "state", default: "open"
    t.text "body"
    t.text "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "user_id"
    t.index ["body"], name: "index_posts_on_body"
    t.index ["code"], name: "index_posts_on_code"
    t.index ["title"], name: "index_posts_on_title"
  end

  create_table "review_coin_transactions", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.bigint "review_id"
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["review_id"], name: "index_review_coin_transactions_on_review_id"
  end

  create_table "review_links", force: :cascade do |t|
    t.integer "from"
    t.integer "to"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.integer "thrown_coins", default: 0
    t.string "user_id"
    t.bigint "post_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "primary"
    t.index ["post_id"], name: "index_reviews_on_post_id"
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
    t.integer "coins"
  end

  add_foreign_key "asked_users", "posts"
  add_foreign_key "asked_users", "users"
  add_foreign_key "master_sessions", "users"
  add_foreign_key "onetime_sessions", "master_sessions"
  add_foreign_key "onetime_sessions", "users"
  add_foreign_key "password_reset_sessions", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "review_coin_transactions", "reviews"
  add_foreign_key "review_coin_transactions", "users", column: "from"
  add_foreign_key "review_coin_transactions", "users", column: "to"
  add_foreign_key "review_links", "reviews", column: "from"
  add_foreign_key "review_links", "reviews", column: "to"
  add_foreign_key "reviews", "posts"
  add_foreign_key "reviews", "users"
end
