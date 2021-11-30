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

ActiveRecord::Schema.define(version: 2021_11_30_021349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "content_genres", id: false, force: :cascade do |t|
    t.bigint "content_id"
    t.bigint "genre_id"
    t.index ["content_id"], name: "index_content_genres_on_content_id"
    t.index ["genre_id"], name: "index_content_genres_on_genre_id"
  end

  create_table "contents", force: :cascade do |t|
    t.string "title", null: false
    t.date "release_year", null: false
    t.date "end_year"
    t.integer "run_time", null: false
    t.string "imdb_id", null: false
    t.integer "content_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "imdb_ratings", force: :cascade do |t|
    t.bigint "content_id"
    t.decimal "rating", null: false
    t.integer "total_votes", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["content_id"], name: "index_imdb_ratings_on_content_id"
  end

  add_foreign_key "content_genres", "contents"
  add_foreign_key "content_genres", "genres"
  add_foreign_key "imdb_ratings", "contents"
end
