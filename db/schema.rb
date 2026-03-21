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

ActiveRecord::Schema[8.1].define(version: 2026_03_21_014419) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "public.achievements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "icon_url"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "xp_reward", default: 0, null: false
    t.index ["key"], name: "index_achievements_on_key", unique: true
  end

  create_table "public.gamification_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "last_activity_date"
    t.integer "level", default: 1, null: false
    t.integer "streak_days", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "xp", default: 0, null: false
    t.index ["user_id"], name: "index_gamification_profiles_on_user_id", unique: true
  end

  create_table "public.items", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.integer "priority", default: 0
    t.integer "recurrence", default: 0
    t.integer "status", default: 0
    t.bigint "task_list_id", null: false
    t.datetime "updated_at", null: false
    t.index ["task_list_id"], name: "index_items_on_task_list_id"
  end

  create_table "public.task_lists", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "status", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_task_lists_on_user_id"
  end

  create_table "public.user_achievements", force: :cascade do |t|
    t.bigint "achievement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "earned_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "public.users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "public.gamification_profiles", "public.users"
  add_foreign_key "public.items", "public.task_lists", on_delete: :cascade
  add_foreign_key "public.task_lists", "public.users", on_delete: :cascade
  add_foreign_key "public.user_achievements", "public.achievements"
  add_foreign_key "public.user_achievements", "public.users"

end
