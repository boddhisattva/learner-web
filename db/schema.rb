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

ActiveRecord::Schema[8.1].define(version: 2026_01_18_152259) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "learning_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false, comment: "User who created the learning category"
    t.datetime "deleted_at"
    t.text "description", comment: "More information about the learning category"
    t.bigint "last_modifier_id", null: false, comment: "User who last modified the learning category"
    t.string "name", null: false, comment: "Name of the learning category"
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_learning_categories_on_creator_id"
    t.index ["deleted_at"], name: "index_learning_categories_on_deleted_at"
    t.index ["last_modifier_id"], name: "index_learning_categories_on_last_modifier_id"
    t.index ["organization_id", "name"], name: "index_learning_categories_on_org_and_name", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_learning_categories_on_organization_id"
  end

  create_table "learning_categorizations", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "learning_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_learning_categorizations_on_category_id"
    t.index ["deleted_at"], name: "index_learning_categorizations_on_deleted_at"
    t.index ["learning_id", "category_id"], name: "index_learning_categorizations_uniqueness", unique: true, where: "(deleted_at IS NULL)"
    t.index ["learning_id"], name: "index_learning_categorizations_on_learning_id"
  end

  create_table "learnings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false, comment: "User who created the learning"
    t.datetime "deleted_at"
    t.text "description", comment: "Learning lesson in more detail"
    t.bigint "last_modifier_id", null: false, comment: "User who last modified the learning"
    t.string "lesson", null: false, comment: "Learning lesson learnt"
    t.bigint "organization_id", null: false, comment: "The organization to which the learning belongs"
    t.datetime "updated_at", null: false
    t.index "lower((lesson)::text) gin_trgm_ops", name: "index_learnings_on_lesson_trgm", using: :gin
    t.index ["creator_id", "organization_id"], name: "index_learnings_on_creator_id_and_organization_id"
    t.index ["creator_id"], name: "index_learnings_on_creator_id"
    t.index ["deleted_at"], name: "index_learnings_on_deleted_at"
    t.index ["last_modifier_id"], name: "index_learnings_on_last_modifier_id"
    t.index ["lesson"], name: "index_learnings_on_lesson"
    t.index ["organization_id"], name: "index_learnings_on_organization_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "learnings_count", default: 0, null: false, comment: "Counter cache for learnings count per user per organization"
    t.bigint "member_id", null: false, comment: "This references the user associated with the membership"
    t.bigint "organization_id", null: false, comment: "This references the organisation associated with the membership"
    t.datetime "updated_at", null: false
    t.index ["member_id", "organization_id"], name: "index_memberships_on_member_id_and_organization_id", unique: true
    t.index ["member_id"], name: "index_memberships_on_member_id"
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organizations_on_name", unique: true
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false, comment: "User email"
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false, comment: "User first name"
    t.string "last_name", null: false, comment: "User last name"
    t.bigint "personal_organization_id"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["personal_organization_id"], name: "index_users_on_personal_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "learning_categories", "organizations"
  add_foreign_key "learning_categories", "users", column: "creator_id"
  add_foreign_key "learning_categories", "users", column: "last_modifier_id"
  add_foreign_key "learning_categorizations", "learning_categories", column: "category_id"
  add_foreign_key "learning_categorizations", "learnings"
  add_foreign_key "learnings", "organizations"
  add_foreign_key "learnings", "users", column: "creator_id"
  add_foreign_key "learnings", "users", column: "last_modifier_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users", column: "member_id"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "users", "organizations", column: "personal_organization_id", validate: false
end
