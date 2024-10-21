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

ActiveRecord::Schema[7.2].define(version: 2024_10_20_080014) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "learning_categories", force: :cascade do |t|
    t.string "name", null: false, comment: "Name of the learning category"
    t.text "description", comment: "More information about the learning category"
    t.bigint "creator_id", null: false, comment: "User who created the learning category"
    t.bigint "last_modifier_id", null: false, comment: "User who last modified the learning category"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_learning_categories_on_creator_id"
    t.index ["deleted_at"], name: "index_learning_categories_on_deleted_at"
    t.index ["last_modifier_id"], name: "index_learning_categories_on_last_modifier_id"
    t.index ["name"], name: "index_learning_categories_on_name", unique: true
  end

  create_table "learnings", force: :cascade do |t|
    t.string "lesson", null: false, comment: "Learning lesson learnt"
    t.text "description", comment: "Learning lesson in more detail"
    t.bigint "creator_id", null: false, comment: "User who created the learning"
    t.datetime "deleted_at"
    t.boolean "public", default: false, null: false, comment: "Determines organizational visibility of the learning"
    t.integer "learning_category_ids", default: [], comment: "Collection of different learning categories a Learning belongs to", array: true
    t.bigint "last_modifier_id", null: false, comment: "User who last modified the learning"
    t.bigint "organization_id", null: false, comment: "The organization to which the learning belongs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_learnings_on_creator_id"
    t.index ["deleted_at"], name: "index_learnings_on_deleted_at"
    t.index ["last_modifier_id"], name: "index_learnings_on_last_modifier_id"
    t.index ["learning_category_ids"], name: "index_learnings_on_learning_category_ids", using: :gin
    t.index ["lesson"], name: "index_learnings_on_lesson"
    t.index ["organization_id"], name: "index_learnings_on_organization_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "member_id", null: false, comment: "This references the user associated with the membership"
    t.bigint "organization_id", null: false, comment: "This references the organisation associated with the membership"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_memberships_on_member_id"
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false, comment: "User first name"
    t.string "last_name", null: false, comment: "User last name"
    t.string "email", default: "", null: false, comment: "User email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "learning_categories", "users", column: "creator_id"
  add_foreign_key "learning_categories", "users", column: "last_modifier_id"
  add_foreign_key "learnings", "organizations"
  add_foreign_key "learnings", "users", column: "creator_id"
  add_foreign_key "learnings", "users", column: "last_modifier_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users", column: "member_id"
end
