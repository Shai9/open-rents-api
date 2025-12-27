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

ActiveRecord::Schema[8.0].define(version: 2025_12_23_213356) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "county"
    t.string "ward"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_neighborhoods_on_name", unique: true
    t.index ["slug"], name: "index_neighborhoods_on_slug", unique: true
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "neighborhood_id", null: false
    t.string "report_type", null: false
    t.string "value", null: false
    t.text "details"
    t.decimal "confidence", precision: 3, scale: 2, default: "0.5"
    t.integer "agreements_count", default: 0
    t.integer "disagreements_count", default: 0
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neighborhood_id"], name: "index_reports_on_neighborhood_id"
    t.index ["report_type", "neighborhood_id"], name: "index_reports_on_report_type_and_neighborhood_id"
    t.index ["user_id", "neighborhood_id", "report_type"], name: "index_reports_on_user_neighborhood_type_unique", unique: true
    t.index ["user_id"], name: "index_reports_on_user_id"
    t.index ["verified_at"], name: "index_reports_on_verified_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "phone_number", null: false
    t.string "sms_verification_code"
    t.datetime "sms_verified_at"
    t.decimal "trust_score", precision: 3, scale: 2, default: "0.5"
    t.integer "reports_count", default: 0
    t.integer "verifications_count", default: 0
    t.decimal "consistency_score", precision: 3, scale: 2, default: "0.5"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "report_id", null: false
    t.boolean "agrees", null: false
    t.text "comment"
    t.decimal "weight", precision: 3, scale: 2, default: "1.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id", "agrees"], name: "index_verifications_on_report_id_and_agrees"
    t.index ["report_id"], name: "index_verifications_on_report_id"
    t.index ["user_id", "report_id"], name: "index_verifications_on_user_id_and_report_id", unique: true
    t.index ["user_id"], name: "index_verifications_on_user_id"
  end

  add_foreign_key "reports", "neighborhoods"
  add_foreign_key "reports", "users"
  add_foreign_key "verifications", "reports"
  add_foreign_key "verifications", "users"
end
