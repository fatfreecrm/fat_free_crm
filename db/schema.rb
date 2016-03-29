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

ActiveRecord::Schema.define(version: 20160329145615) do

  create_table "account_contacts", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "contact_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "account_opportunities", force: :cascade do |t|
    t.integer  "account_id",     limit: 4
    t.integer  "opportunity_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_opportunities", ["account_id", "opportunity_id"], name: "index_account_opportunities_on_account_id_and_opportunity_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "assigned_to",      limit: 4
    t.string   "name",             limit: 64,    default: "",       null: false
    t.string   "access",           limit: 8,     default: "Public"
    t.string   "website",          limit: 64
    t.string   "toll_free_phone",  limit: 32
    t.string   "phone",            limit: 32
    t.string   "fax",              limit: 32
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",            limit: 254
    t.string   "background_info",  limit: 255
    t.integer  "rating",           limit: 4,     default: 0,        null: false
    t.string   "category",         limit: 32
    t.text     "subscribed_users", limit: 65535
  end

  add_index "accounts", ["assigned_to"], name: "index_accounts_on_assigned_to", using: :btree
  add_index "accounts", ["user_id", "name", "deleted_at"], name: "index_accounts_on_user_id_and_name_and_deleted_at", unique: true, using: :btree

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "subject_id",   limit: 4
    t.string   "subject_type", limit: 255
    t.string   "action",       limit: 32,  default: "created"
    t.string   "info",         limit: 255, default: ""
    t.boolean  "private",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["created_at"], name: "index_activities_on_created_at", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "street1",          limit: 255
    t.string   "street2",          limit: 255
    t.string   "city",             limit: 64
    t.string   "state",            limit: 64
    t.string   "zipcode",          limit: 16
    t.string   "country",          limit: 64
    t.string   "full_address",     limit: 255
    t.string   "address_type",     limit: 16
    t.integer  "addressable_id",   limit: 4
    t.string   "addressable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type", using: :btree

  create_table "avatars", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.integer  "entity_id",          limit: 4
    t.string   "entity_type",        limit: 255
    t.integer  "image_file_size",    limit: 4
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.integer  "assigned_to",         limit: 4
    t.string   "name",                limit: 64,                             default: "",       null: false
    t.string   "access",              limit: 8,                              default: "Public"
    t.string   "status",              limit: 64
    t.decimal  "budget",                            precision: 12, scale: 2
    t.integer  "target_leads",        limit: 4
    t.float    "target_conversion",   limit: 24
    t.decimal  "target_revenue",                    precision: 12, scale: 2
    t.integer  "leads_count",         limit: 4
    t.integer  "opportunities_count", limit: 4
    t.decimal  "revenue",                           precision: 12, scale: 2
    t.date     "starts_on"
    t.date     "ends_on"
    t.text     "objectives",          limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info",     limit: 255
    t.text     "subscribed_users",    limit: 65535
  end

  add_index "campaigns", ["assigned_to"], name: "index_campaigns_on_assigned_to", using: :btree
  add_index "campaigns", ["user_id", "name", "deleted_at"], name: "index_campaigns_on_user_id_and_name_and_deleted_at", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.boolean  "private"
    t.string   "title",            limit: 255,   default: ""
    t.text     "comment",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",            limit: 16,    default: "Expanded", null: false
  end

  create_table "contact_opportunities", force: :cascade do |t|
    t.integer  "contact_id",     limit: 4
    t.integer  "opportunity_id", limit: 4
    t.string   "role",           limit: 32
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_opportunities", ["contact_id", "opportunity_id"], name: "index_contact_opportunities_on_contact_id_and_opportunity_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "lead_id",          limit: 4
    t.integer  "assigned_to",      limit: 4
    t.integer  "reports_to",       limit: 4
    t.string   "first_name",       limit: 64,    default: "",       null: false
    t.string   "last_name",        limit: 64,    default: "",       null: false
    t.string   "access",           limit: 8,     default: "Public"
    t.string   "title",            limit: 64
    t.string   "department",       limit: 64
    t.string   "source",           limit: 32
    t.string   "email",            limit: 254
    t.string   "alt_email",        limit: 254
    t.string   "phone",            limit: 32
    t.string   "mobile",           limit: 32
    t.string   "fax",              limit: 32
    t.string   "blog",             limit: 128
    t.string   "linkedin",         limit: 128
    t.string   "facebook",         limit: 128
    t.string   "twitter",          limit: 128
    t.date     "born_on"
    t.boolean  "do_not_call",                    default: false,    null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info",  limit: 255
    t.string   "skype",            limit: 128
    t.text     "subscribed_users", limit: 65535
  end

  add_index "contacts", ["assigned_to"], name: "index_contacts_on_assigned_to", using: :btree
  add_index "contacts", ["user_id", "last_name", "deleted_at"], name: "id_last_name_deleted", unique: true, using: :btree

  create_table "contracts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "emails", force: :cascade do |t|
    t.string   "imap_message_id", limit: 255,                        null: false
    t.integer  "user_id",         limit: 4
    t.integer  "mediator_id",     limit: 4
    t.string   "mediator_type",   limit: 255
    t.string   "sent_from",       limit: 255,                        null: false
    t.string   "sent_to",         limit: 255,                        null: false
    t.string   "cc",              limit: 255
    t.string   "bcc",             limit: 255
    t.string   "subject",         limit: 255
    t.text     "body",            limit: 65535
    t.text     "header",          limit: 65535
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",           limit: 16,    default: "Expanded", null: false
  end

  add_index "emails", ["mediator_id", "mediator_type"], name: "index_emails_on_mediator_id_and_mediator_type", using: :btree

  create_table "field_groups", force: :cascade do |t|
    t.string   "name",       limit: 64
    t.string   "label",      limit: 128
    t.integer  "position",   limit: 4
    t.string   "hint",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_id",     limit: 4
    t.string   "klass_name", limit: 32
  end

  create_table "fields", force: :cascade do |t|
    t.string   "type",           limit: 255
    t.integer  "field_group_id", limit: 4
    t.integer  "position",       limit: 4
    t.string   "name",           limit: 64
    t.string   "label",          limit: 128
    t.string   "hint",           limit: 255
    t.string   "placeholder",    limit: 255
    t.string   "as",             limit: 32
    t.text     "collection",     limit: 65535
    t.boolean  "disabled"
    t.boolean  "required"
    t.integer  "maxlength",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pair_id",        limit: 4
    t.text     "settings",       limit: 65535
  end

  add_index "fields", ["field_group_id"], name: "index_fields_on_field_group_id", using: :btree
  add_index "fields", ["name"], name: "index_fields_on_name", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id", limit: 4
    t.integer "user_id",  limit: 4
  end

  add_index "groups_users", ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", using: :btree
  add_index "groups_users", ["group_id"], name: "index_groups_users_on_group_id", using: :btree
  add_index "groups_users", ["user_id"], name: "index_groups_users_on_user_id", using: :btree

  create_table "kiosks", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.date     "purchase_date"
    t.integer  "contract_length", limit: 4
    t.string   "password",        limit: 255
    t.string   "cd_password",     limit: 255
    t.text     "notes",           limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "account_id",      limit: 4
    t.integer  "contract_id",     limit: 4
  end

  add_index "kiosks", ["account_id"], name: "index_kiosks_on_account_id", using: :btree
  add_index "kiosks", ["contract_id"], name: "index_kiosks_on_contract_id", using: :btree
  add_index "kiosks", ["name"], name: "index_kiosks_on_name", unique: true, using: :btree

  create_table "leads", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "campaign_id",      limit: 4
    t.integer  "assigned_to",      limit: 4
    t.string   "first_name",       limit: 64,    default: "",       null: false
    t.string   "last_name",        limit: 64,    default: "",       null: false
    t.string   "access",           limit: 8,     default: "Public"
    t.string   "title",            limit: 64
    t.string   "company",          limit: 64
    t.string   "source",           limit: 32
    t.string   "status",           limit: 32
    t.string   "referred_by",      limit: 64
    t.string   "email",            limit: 254
    t.string   "alt_email",        limit: 254
    t.string   "phone",            limit: 32
    t.string   "mobile",           limit: 32
    t.string   "blog",             limit: 128
    t.string   "linkedin",         limit: 128
    t.string   "facebook",         limit: 128
    t.string   "twitter",          limit: 128
    t.integer  "rating",           limit: 4,     default: 0,        null: false
    t.boolean  "do_not_call",                    default: false,    null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info",  limit: 255
    t.string   "skype",            limit: 128
    t.text     "subscribed_users", limit: 65535
  end

  add_index "leads", ["assigned_to"], name: "index_leads_on_assigned_to", using: :btree
  add_index "leads", ["user_id", "last_name", "deleted_at"], name: "index_leads_on_user_id_and_last_name_and_deleted_at", unique: true, using: :btree

  create_table "lists", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "url",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
  end

  add_index "lists", ["user_id"], name: "index_lists_on_user_id", using: :btree

  create_table "opportunities", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "campaign_id",      limit: 4
    t.integer  "assigned_to",      limit: 4
    t.string   "name",             limit: 64,                             default: "",       null: false
    t.string   "access",           limit: 8,                              default: "Public"
    t.string   "source",           limit: 32
    t.string   "stage",            limit: 32
    t.integer  "probability",      limit: 4
    t.decimal  "amount",                         precision: 12, scale: 2
    t.decimal  "discount",                       precision: 12, scale: 2
    t.date     "closes_on"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info",  limit: 255
    t.text     "subscribed_users", limit: 65535
  end

  add_index "opportunities", ["assigned_to"], name: "index_opportunities_on_assigned_to", using: :btree
  add_index "opportunities", ["user_id", "name", "deleted_at"], name: "id_name_deleted", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "asset_id",   limit: 4
    t.string   "asset_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",   limit: 4
  end

  add_index "permissions", ["asset_id", "asset_type"], name: "index_permissions_on_asset_id_and_asset_type", using: :btree
  add_index "permissions", ["group_id"], name: "index_permissions_on_group_id", using: :btree
  add_index "permissions", ["user_id"], name: "index_permissions_on_user_id", using: :btree

  create_table "preferences", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 32,    default: "", null: false
    t.text     "value",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["user_id", "name"], name: "index_preferences_on_user_id_and_name", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "name",       limit: 32,    default: "", null: false
    t.text     "value",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["name"], name: "index_settings_on_name", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "taggable_type", limit: 50
    t.string   "context",       limit: 50
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tasks", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "assigned_to",      limit: 4
    t.integer  "completed_by",     limit: 4
    t.string   "name",             limit: 255,   default: "", null: false
    t.integer  "asset_id",         limit: 4
    t.string   "asset_type",       limit: 255
    t.string   "priority",         limit: 32
    t.string   "category",         limit: 32
    t.string   "bucket",           limit: 32
    t.datetime "due_at"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info",  limit: 255
    t.text     "subscribed_users", limit: 65535
  end

  add_index "tasks", ["assigned_to"], name: "index_tasks_on_assigned_to", using: :btree
  add_index "tasks", ["user_id", "name", "deleted_at"], name: "index_tasks_on_user_id_and_name_and_deleted_at", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",            limit: 32,  default: "",    null: false
    t.string   "email",               limit: 254, default: "",    null: false
    t.string   "first_name",          limit: 32
    t.string   "last_name",           limit: 32
    t.string   "title",               limit: 64
    t.string   "company",             limit: 64
    t.string   "alt_email",           limit: 254
    t.string   "phone",               limit: 32
    t.string   "mobile",              limit: 32
    t.string   "aim",                 limit: 32
    t.string   "yahoo",               limit: 32
    t.string   "google",              limit: 32
    t.string   "skype",               limit: 32
    t.string   "password_hash",       limit: 255, default: "",    null: false
    t.string   "password_salt",       limit: 255, default: "",    null: false
    t.string   "persistence_token",   limit: 255, default: "",    null: false
    t.string   "perishable_token",    limit: 255, default: "",    null: false
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip",       limit: 255
    t.string   "current_login_ip",    limit: 255
    t.integer  "login_count",         limit: 4,   default: 0,     null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                           default: false, null: false
    t.datetime "suspended_at"
    t.string   "single_access_token", limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["perishable_token"], name: "index_users_on_perishable_token", using: :btree
  add_index "users", ["persistence_token"], name: "index_users_on_persistence_token", using: :btree
  add_index "users", ["username", "deleted_at"], name: "index_users_on_username_and_deleted_at", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,   null: false
    t.integer  "item_id",        limit: 4,     null: false
    t.string   "event",          limit: 512,   null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 65535
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
    t.integer  "related_id",     limit: 4
    t.string   "related_type",   limit: 255
    t.integer  "transaction_id", limit: 4
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["related_id", "related_type"], name: "index_versions_on_related_id_and_related_type", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree
  add_index "versions", ["whodunnit"], name: "index_versions_on_whodunnit", using: :btree

  add_foreign_key "kiosks", "accounts"
  add_foreign_key "kiosks", "contracts"
end
