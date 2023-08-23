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

ActiveRecord::Schema[7.0].define(version: 2023_08_23_122131) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "game_players", force: :cascade do |t|
    t.integer "position"
    t.integer "game_id"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "state", limit: 30, default: "created", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state"], name: "index_games_on_state"
  end

  create_table "players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_players_on_name"
  end

end
