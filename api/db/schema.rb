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

ActiveRecord::Schema[8.1].define(version: 2026_02_05_191144) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assets", force: :cascade do |t|
    t.jsonb "aliases", default: []
    t.string "asset_class", null: false
    t.string "coingecko_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "symbol", null: false
    t.datetime "updated_at", null: false
    t.string "yahoo_ticker"
    t.index ["asset_class"], name: "index_assets_on_asset_class"
    t.index ["symbol"], name: "index_assets_on_symbol", unique: true
  end

  create_table "calls", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.datetime "called_at", null: false
    t.decimal "confidence", precision: 5, scale: 4, null: false
    t.bigint "content_id", null: false
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.bigint "influencer_id", null: false
    t.text "quote"
    t.text "reasoning"
    t.datetime "updated_at", null: false
    t.index ["asset_id", "called_at"], name: "index_calls_on_asset_id_and_called_at"
    t.index ["asset_id"], name: "index_calls_on_asset_id"
    t.index ["content_id"], name: "index_calls_on_content_id"
    t.index ["direction"], name: "index_calls_on_direction"
    t.index ["influencer_id", "called_at"], name: "index_calls_on_influencer_id_and_called_at"
    t.index ["influencer_id"], name: "index_calls_on_influencer_id"
  end

  create_table "contents", force: :cascade do |t|
    t.text "body"
    t.datetime "calls_extracted_at"
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.string "extraction_status", default: "pending"
    t.bigint "influencer_id", null: false
    t.jsonb "metadata", default: {}
    t.datetime "published_at"
    t.string "title"
    t.text "transcript"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["calls_extracted_at"], name: "index_contents_on_calls_extracted_at"
    t.index ["external_id", "type"], name: "index_contents_on_external_id_and_type", unique: true
    t.index ["extraction_status"], name: "index_contents_on_extraction_status"
    t.index ["influencer_id", "published_at"], name: "index_contents_on_influencer_id_and_published_at"
    t.index ["influencer_id"], name: "index_contents_on_influencer_id"
    t.index ["type"], name: "index_contents_on_type"
  end

  create_table "influencers", force: :cascade do |t|
    t.string "avatar_url"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_influencers_on_name"
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "invited_by_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_invitations_on_email", unique: true
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
  end

  create_table "price_snapshots", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.decimal "close", precision: 20, scale: 8, null: false
    t.datetime "created_at", null: false
    t.decimal "high", precision: 20, scale: 8
    t.decimal "low", precision: 20, scale: 8
    t.decimal "open", precision: 20, scale: 8
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.bigint "volume"
    t.index ["asset_id", "timestamp"], name: "index_price_snapshots_on_asset_id_and_timestamp", unique: true
    t.index ["asset_id"], name: "index_price_snapshots_on_asset_id"
    t.index ["timestamp"], name: "index_price_snapshots_on_timestamp"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "twitter_accounts", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.bigint "influencer_id", null: false
    t.datetime "last_synced_at"
    t.string "profile_image_url"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["influencer_id"], name: "index_twitter_accounts_on_influencer_id"
    t.index ["username"], name: "index_twitter_accounts_on_username", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "youtube_channels", force: :cascade do |t|
    t.string "channel_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "influencer_id", null: false
    t.datetime "last_synced_at"
    t.string "thumbnail_url"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "uploads_playlist_id"
    t.index ["channel_id"], name: "index_youtube_channels_on_channel_id", unique: true
    t.index ["influencer_id"], name: "index_youtube_channels_on_influencer_id"
  end

  add_foreign_key "calls", "assets"
  add_foreign_key "calls", "contents"
  add_foreign_key "calls", "influencers"
  add_foreign_key "contents", "influencers"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "price_snapshots", "assets"
  add_foreign_key "sessions", "users"
  add_foreign_key "twitter_accounts", "influencers"
  add_foreign_key "youtube_channels", "influencers"
end
