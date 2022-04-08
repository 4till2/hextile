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

ActiveRecord::Schema[7.0].define(version: 2022_04_08_150008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.integer "expires_at"
    t.string "refresh_token"
    t.string "scope"
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "email"
    t.boolean "confirmed"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "waypoints", force: :cascade do |t|
    t.string "title"
    t.float "longitude"
    t.float "latitude"
    t.float "elevation"
    t.json "geocode"
    t.datetime "external_created_at"
    t.datetime "external_updated_at"
    t.integer "external_id"
    t.string "external_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
