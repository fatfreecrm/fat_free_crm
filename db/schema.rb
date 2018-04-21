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

ActiveRecord::Schema.define(version: 20180107082701) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_contacts", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "contact_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id", "contact_id"], name: "index_account_contacts_on_account_id_and_contact_id"
  end

  create_table "account_opportunities", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "opportunity_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id", "opportunity_id"], name: "index_account_opportunities_on_account_id_and_opportunity_id"
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "assigned_to"
    t.string "name", limit: 64, default: "", null: false
    t.string "access", limit: 8, default: "Public"
    t.string "website", limit: 64
    t.string "toll_free_phone", limit: 32
    t.string "phone", limit: 32
    t.string "fax", limit: 32
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", limit: 254
    t.string "background_info"
    t.integer "rating", default: 0, null: false
    t.string "category", limit: 32
    t.text "subscribed_users"
    t.integer "contacts_count", default: 0
    t.integer "opportunities_count", default: 0
    t.integer "pipeline_opportunities_count", default: 0
    t.index ["assigned_to"], name: "index_accounts_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_accounts_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "subject_type"
    t.integer "subject_id"
    t.string "action", limit: 32, default: "created"
    t.string "info", default: ""
    t.boolean "private", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "street1"
    t.string "street2"
    t.string "city", limit: 64
    t.string "state", limit: 64
    t.string "zipcode", limit: 16
    t.string "country", limit: 64
    t.string "full_address"
    t.string "address_type", limit: 16
    t.string "addressable_type"
    t.integer "addressable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type"
  end

  create_table "avatars", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "entity_type"
    t.integer "entity_id"
    t.integer "image_file_size"
    t.string "image_file_name"
    t.string "image_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "assigned_to"
    t.string "name", limit: 64, default: "", null: false
    t.string "access", limit: 8, default: "Public"
    t.string "status", limit: 64
    t.decimal "budget", precision: 12, scale: 2
    t.integer "target_leads"
    t.float "target_conversion"
    t.decimal "target_revenue", precision: 12, scale: 2
    t.integer "leads_count"
    t.integer "opportunities_count"
    t.decimal "revenue", precision: 12, scale: 2
    t.date "starts_on"
    t.date "ends_on"
    t.text "objectives"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "background_info"
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_campaigns_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_campaigns_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.boolean "private"
    t.string "title", default: ""
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "state", limit: 16, default: "Expanded", null: false
  end

  create_table "contact_opportunities", id: :serial, force: :cascade do |t|
    t.integer "contact_id"
    t.integer "opportunity_id"
    t.string "role", limit: 32
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contact_id", "opportunity_id"], name: "index_contact_opportunities_on_contact_id_and_opportunity_id"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "lead_id"
    t.integer "assigned_to"
    t.integer "reports_to"
    t.string "first_name", limit: 64, default: "", null: false
    t.string "last_name", limit: 64, default: "", null: false
    t.string "access", limit: 8, default: "Public"
    t.string "title", limit: 64
    t.string "department", limit: 64
    t.string "source", limit: 32
    t.string "email", limit: 254
    t.string "alt_email", limit: 254
    t.string "phone", limit: 32
    t.string "mobile", limit: 32
    t.string "fax", limit: 32
    t.string "blog", limit: 128
    t.string "linkedin", limit: 128
    t.string "facebook", limit: 128
    t.string "twitter", limit: 128
    t.date "born_on"
    t.boolean "do_not_call", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "background_info"
    t.string "skype", limit: 128
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_contacts_on_assigned_to"
    t.index ["user_id", "last_name", "deleted_at"], name: "id_last_name_deleted", unique: true
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.string "imap_message_id", null: false
    t.integer "user_id"
    t.string "mediator_type"
    t.integer "mediator_id"
    t.string "sent_from", null: false
    t.string "sent_to", null: false
    t.string "cc"
    t.string "bcc"
    t.string "subject"
    t.text "body"
    t.text "header"
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "state", limit: 16, default: "Expanded", null: false
    t.index ["mediator_id", "mediator_type"], name: "index_emails_on_mediator_id_and_mediator_type"
  end

  create_table "field_groups", id: :serial, force: :cascade do |t|
    t.string "name", limit: 64
    t.string "label", limit: 128
    t.integer "position"
    t.string "hint"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tag_id"
    t.string "klass_name", limit: 32
  end

  create_table "fields", id: :serial, force: :cascade do |t|
    t.string "type"
    t.integer "field_group_id"
    t.integer "position"
    t.string "name", limit: 64
    t.string "label", limit: 128
    t.string "hint"
    t.string "placeholder"
    t.string "as", limit: 32
    t.text "collection"
    t.boolean "disabled"
    t.boolean "required"
    t.integer "maxlength"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pair_id"
    t.text "settings"
    t.integer "minlength", default: 0
    t.index ["field_group_id"], name: "index_fields_on_field_group_id"
    t.index ["name"], name: "index_fields_on_name"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "leads", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "campaign_id"
    t.integer "assigned_to"
    t.string "first_name", limit: 64, default: "", null: false
    t.string "last_name", limit: 64, default: "", null: false
    t.string "access", limit: 8, default: "Public"
    t.string "title", limit: 64
    t.string "company", limit: 64
    t.string "source", limit: 32
    t.string "status", limit: 32
    t.string "referred_by", limit: 64
    t.string "email", limit: 254
    t.string "alt_email", limit: 254
    t.string "phone", limit: 32
    t.string "mobile", limit: 32
    t.string "blog", limit: 128
    t.string "linkedin", limit: 128
    t.string "facebook", limit: 128
    t.string "twitter", limit: 128
    t.integer "rating", default: 0, null: false
    t.boolean "do_not_call", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "background_info"
    t.string "skype", limit: 128
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_leads_on_assigned_to"
    t.index ["user_id", "last_name", "deleted_at"], name: "index_leads_on_user_id_and_last_name_and_deleted_at", unique: true
  end

  create_table "lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "opportunities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "campaign_id"
    t.integer "assigned_to"
    t.string "name", limit: 64, default: "", null: false
    t.string "access", limit: 8, default: "Public"
    t.string "source", limit: 32
    t.string "stage", limit: 32
    t.integer "probability"
    t.decimal "amount", precision: 12, scale: 2
    t.decimal "discount", precision: 12, scale: 2
    t.date "closes_on"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "background_info"
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_opportunities_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "id_name_deleted", unique: true
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "asset_type"
    t.integer "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "group_id"
    t.index ["asset_id", "asset_type"], name: "index_permissions_on_asset_id_and_asset_type"
    t.index ["group_id"], name: "index_permissions_on_group_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 32, default: "", null: false
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "name"], name: "index_preferences_on_user_id_and_name"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "name", limit: 32, default: "", null: false
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_settings_on_name"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "taggable_type", limit: 50
    t.string "context", limit: 50
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "assigned_to"
    t.integer "completed_by"
    t.string "name", default: "", null: false
    t.string "asset_type"
    t.integer "asset_id"
    t.string "priority", limit: 32
    t.string "category", limit: 32
    t.string "bucket", limit: 32
    t.datetime "due_at"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "background_info"
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_tasks_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_tasks_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", limit: 32, default: "", null: false
    t.string "email", limit: 254, default: "", null: false
    t.string "first_name", limit: 32
    t.string "last_name", limit: 32
    t.string "title", limit: 64
    t.string "company", limit: 64
    t.string "alt_email", limit: 254
    t.string "phone", limit: 32
    t.string "mobile", limit: 32
    t.string "aim", limit: 32
    t.string "yahoo", limit: 32
    t.string "google", limit: 32
    t.string "skype", limit: 32
    t.string "encrypted_password", default: "", null: false
    t.string "password_salt", default: "", null: false
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "current_sign_in_ip"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin", default: false, null: false
    t.datetime "suspended_at"
    t.string "unconfirmed_email", limit: 254
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.string "authentication_token"
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username", "deleted_at"], name: "index_users_on_username_and_deleted_at", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", limit: 512, null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "related_id"
    t.string "related_type"
    t.integer "transaction_id"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["related_id", "related_type"], name: "index_versions_on_related_id_and_related_type"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

end
