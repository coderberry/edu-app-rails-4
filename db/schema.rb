# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130823212611) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: true do |t|
    t.integer  "tokenable_id"
    t.string   "tokenable_type"
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "expired_at"
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.json     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cartridges", force: true do |t|
    t.string   "uid"
    t.string   "name",       null: false
    t.text     "xml"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cartridges", ["uid"], name: "index_cartridges_on_uid", unique: true, using: :btree
  add_index "cartridges", ["user_id"], name: "index_cartridges_on_user_id", using: :btree

  create_table "lti_app_configurations", force: true do |t|
    t.string   "short_name", null: false
    t.json     "config"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lti_app_configurations", ["short_name"], name: "index_lti_app_configurations_on_short_name", unique: true, using: :btree
  add_index "lti_app_configurations", ["user_id"], name: "index_lti_app_configurations_on_user_id", using: :btree

  create_table "lti_apps", force: true do |t|
    t.integer  "user_id"
    t.string   "short_name",                                                 null: false
    t.string   "name",                                                       null: false
    t.string   "short_description"
    t.text     "description"
    t.string   "status",                                 default: "pending", null: false
    t.text     "testing_instructions"
    t.string   "support_url",               limit: 1000
    t.string   "author_name"
    t.boolean  "is_public",                              default: false
    t.string   "app_type"
    t.string   "ims_cert_url",              limit: 1000
    t.string   "preview_url",               limit: 1000
    t.string   "config_url",                limit: 1000
    t.string   "data_url",                  limit: 1000
    t.string   "banner_image_url",          limit: 1000
    t.string   "logo_image_url",            limit: 1000
    t.string   "icon_image_url",            limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "cartridge_id"
    t.text     "installation_instructions"
    t.integer  "lti_app_configuration_id"
  end

  add_index "lti_apps", ["cartridge_id"], name: "index_lti_apps_on_cartridge_id", using: :btree
  add_index "lti_apps", ["lti_app_configuration_id"], name: "index_lti_apps_on_lti_app_configuration_id", using: :btree
  add_index "lti_apps", ["organization_id"], name: "index_lti_apps_on_organization_id", using: :btree
  add_index "lti_apps", ["short_name"], name: "index_lti_apps_on_short_name", unique: true, using: :btree
  add_index "lti_apps", ["user_id"], name: "index_lti_apps_on_user_id", using: :btree

  create_table "lti_apps_tags", force: true do |t|
    t.integer "lti_app_id"
    t.integer "tag_id"
  end

  add_index "lti_apps_tags", ["lti_app_id", "tag_id"], name: "index_lti_apps_tags", unique: true, using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "remote_uid"
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["organization_id"], name: "index_memberships_on_organization_id", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_list_anonymous_only",                     default: false
    t.boolean  "is_list_apps_without_approval",              default: false
    t.string   "url",                           limit: 1000
  end

  create_table "registration_codes", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "code"
    t.datetime "valid_until"
  end

  add_index "registration_codes", ["code"], name: "index_registration_codes_on_code", using: :btree

  create_table "reviews", force: true do |t|
    t.integer  "membership_id"
    t.integer  "user_id"
    t.integer  "lti_app_id"
    t.integer  "rating"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["lti_app_id"], name: "index_reviews_on_lti_app_id", using: :btree
  add_index "reviews", ["membership_id"], name: "index_reviews_on_membership_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "short_name"
    t.string   "name"
    t.string   "context"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["short_name"], name: "index_tags_on_short_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "avatar_url",       limit: 1000
    t.string   "url",              limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter_nickname"
  end

  add_index "users", ["twitter_nickname"], name: "index_users_on_twitter_nickname", unique: true, using: :btree

end
