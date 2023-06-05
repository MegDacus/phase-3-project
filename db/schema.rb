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

ActiveRecord::Schema.define(version: 2023_06_05_072325) do

  create_table "bookshelves", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "summary"
    t.string "categories"
    t.integer "price"
    t.integer "isbn"
    t.integer "user_id"
    t.string "google_book_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
  end

  add_foreign_key "bookshelves", "users"
end
