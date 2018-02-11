# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180211121522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agreement_comments", id: :serial, force: :cascade do |t|
    t.integer "individual_id"
    t.integer "agreement_id"
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agreements", id: :serial, force: :cascade do |t|
    t.string "url", limit: 255
    t.integer "individual_id"
    t.integer "statement_id"
    t.integer "extent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hashed_id", limit: 255
    t.text "reason"
    t.integer "reason_category_id"
    t.integer "added_by_id"
    t.integer "upvotes_count", default: 0
    t.index ["hashed_id"], name: "index_agreements_on_hashed_id"
    t.index ["statement_id", "created_at"], name: "index_agreements_on_statement_id_and_created_at"
  end

  create_table "beta_emails", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "individual_id"
    t.integer "statement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "source", limit: 255
  end

  create_table "delegations", id: :serial, force: :cascade do |t|
    t.integer "representative_id"
    t.integer "represented_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", id: :serial, force: :cascade do |t|
    t.integer "followable_id", null: false
    t.string "followable_type", limit: 255, null: false
    t.integer "follower_id", null: false
    t.string "follower_type", limit: 255, null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["followable_id", "followable_type"], name: "fk_followables"
    t.index ["follower_id", "follower_type"], name: "fk_follows"
  end

  create_table "individuals", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "twitter", limit: 255
    t.string "picture_file_name", limit: 255
    t.string "picture_content_type", limit: 255
    t.integer "picture_file_size"
    t.datetime "picture_updated_at"
    t.string "uid", limit: 255
    t.integer "followers_count"
    t.string "email", limit: 255
    t.integer "entrepreneurship_statements_count", default: 0
    t.string "description", limit: 255
    t.text "bio"
    t.string "hashed_id", limit: 255
    t.boolean "update_picture", default: true
    t.integer "ranking", default: 0
    t.integer "profession_id"
    t.string "password_digest", limit: 255
    t.string "activation_digest", limit: 255
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest", limit: 255
    t.datetime "reset_sent_at"
    t.string "wikipedia", limit: 255
    t.string "wikidata_id", limit: 255
    t.string "bio_link", limit: 255
    t.integer "opinions_count", default: 0
    t.boolean "nobel_laureate", default: false, null: false
    t.boolean "admin", default: false
  end

  create_table "old_statement_urls", force: :cascade do |t|
    t.integer "statement_id"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "professions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reason_categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "relationships", id: :serial, force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statements", id: :serial, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hashed_id", limit: 255
    t.integer "agree_counter", default: 0
    t.integer "disagree_counter", default: 0
    t.integer "individual_id"
    t.integer "opinions_count", default: 0
    t.string "url"
    t.string "picture_file_name"
    t.string "picture_content_type"
    t.integer "picture_file_size"
    t.datetime "picture_updated_at"
    t.text "description"
    t.index ["hashed_id"], name: "index_statements_on_hashed_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type", limit: 255
    t.integer "tagger_id"
    t.string "tagger_type", limit: 255
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "upvotes", id: :serial, force: :cascade do |t|
    t.integer "individual_id", null: false
    t.integer "agreement_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "via", id: :serial, force: :cascade do |t|
    t.integer "agreement_id"
    t.integer "individual_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
