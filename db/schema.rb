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

ActiveRecord::Schema[8.0].define(version: 2026_08_04_200359) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "choices", force: :cascade do |t|
    t.bigint "scene_id", null: false
    t.bigint "next_scene_id", null: false
    t.string "text", null: false
    t.text "result_text", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["next_scene_id"], name: "index_choices_on_next_scene_id"
    t.index ["scene_id"], name: "index_choices_on_scene_id"
  end

  create_table "gamebooks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "summary"
    t.string "genre"
    t.text "world_setting"
    t.string "tone"
    t.string "difficulty"
    t.integer "play_time"
    t.integer "generation_status", default: 0, null: false
    t.string "openai_response_id"
    t.text "generation_error_message"
    t.datetime "generated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_gamebooks_on_user_id"
  end

  create_table "scenes", force: :cascade do |t|
    t.bigint "gamebook_id", null: false
    t.string "scene_key", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.text "situation", null: false
    t.integer "scene_type", null: false
    t.boolean "is_start", default: false, null: false
    t.boolean "is_ending", default: false, null: false
    t.integer "ending_type"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gamebook_id"], name: "index_scenes_on_gamebook_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "crypted_password", null: false
    t.string "salt", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "choices", "scenes"
  add_foreign_key "choices", "scenes", column: "next_scene_id"
  add_foreign_key "gamebooks", "users"
  add_foreign_key "scenes", "gamebooks"
end
