# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_04_111522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "fat_free_crm_absences", force: :cascade do |t|
    t.bigint "contact_id"
    t.string "kind"
    t.date "start_on"
    t.date "end_on"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_fat_free_crm_absences_on_contact_id"
  end

  create_table "fat_free_crm_account_contacts", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "contact_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id", "contact_id"], name: "account_contacts_index"
  end

  create_table "fat_free_crm_account_opportunities", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "opportunity_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id", "opportunity_id"], name: "account_opportunities_index"
  end

  create_table "fat_free_crm_accounts", id: :serial, force: :cascade do |t|
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
    t.string "division_name"
    t.bigint "reports_to_id"
    t.index ["assigned_to"], name: "index_fat_free_crm_accounts_on_assigned_to"
    t.index ["reports_to_id"], name: "index_fat_free_crm_accounts_on_reports_to_id"
    t.index ["user_id", "name", "deleted_at"], name: "index_fat_free_crm_accounts_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "fat_free_crm_accounts_facilities", id: false, force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "facility_id"
    t.index ["account_id"], name: "index_fat_free_crm_accounts_facilities_on_account_id"
    t.index ["facility_id"], name: "index_fat_free_crm_accounts_facilities_on_facility_id"
  end

  create_table "fat_free_crm_activities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "subject_type"
    t.integer "subject_id"
    t.string "action", limit: 32, default: "created"
    t.string "info", default: ""
    t.boolean "private", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_at"], name: "index_fat_free_crm_activities_on_created_at"
    t.index ["user_id"], name: "index_fat_free_crm_activities_on_user_id"
  end

  create_table "fat_free_crm_addresses", id: :serial, force: :cascade do |t|
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
    t.point "lonlat"
    t.string "county"
    t.integer "state_code"
    t.integer "county_code"
    t.index ["addressable_id", "addressable_type"], name: "addresses_id_and_type"
  end

  create_table "fat_free_crm_assignments", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "facility_id"
    t.bigint "contact_id"
    t.date "start_on"
    t.date "end_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_fat_free_crm_assignments_on_account_id"
    t.index ["contact_id"], name: "index_fat_free_crm_assignments_on_contact_id"
    t.index ["facility_id"], name: "index_fat_free_crm_assignments_on_facility_id"
  end

  create_table "fat_free_crm_avatars", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "entity_type"
    t.integer "entity_id"
    t.integer "image_file_size"
    t.string "image_file_name"
    t.string "image_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fat_free_crm_campaigns", id: :serial, force: :cascade do |t|
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
    t.index ["assigned_to"], name: "index_fat_free_crm_campaigns_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_fat_free_crm_campaigns_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "fat_free_crm_comments", id: :serial, force: :cascade do |t|
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

  create_table "fat_free_crm_contact_opportunities", id: :serial, force: :cascade do |t|
    t.integer "contact_id"
    t.integer "opportunity_id"
    t.string "role", limit: 32
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contact_id", "opportunity_id"], name: "contact_opportunities_index"
  end

  create_table "fat_free_crm_contacts", id: :serial, force: :cascade do |t|
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
    t.string "gender"
    t.string "preferred_name"
    t.string "preferred_language"
    t.integer "outreach_priority"
    t.string "category"
    t.string "used_interpreter"
    t.index ["assigned_to"], name: "index_fat_free_crm_contacts_on_assigned_to"
    t.index ["user_id", "last_name", "deleted_at"], name: "id_last_name_deleted", unique: true
  end

  create_table "fat_free_crm_details", force: :cascade do |t|
    t.string "name"
    t.string "kind"
    t.bigint "unit_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["unit_id"], name: "index_fat_free_crm_details_on_unit_id"
  end

  create_table "fat_free_crm_documents", force: :cascade do |t|
    t.string "title"
    t.string "creator"
    t.string "subject"
    t.string "description"
    t.string "publisher"
    t.string "contributor"
    t.date "date"
    t.string "type"
    t.string "format"
    t.string "identifier"
    t.string "source"
    t.string "language"
    t.string "relation"
    t.string "coverage"
    t.string "rights"
    t.string "size"
    t.text "tags"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "record_id"
    t.string "record_klass"
    t.string "uploaded_by_id"
  end

  create_table "fat_free_crm_emails", id: :serial, force: :cascade do |t|
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
    t.index ["mediator_id", "mediator_type"], name: "emails_mediator_id_n_type"
  end

  create_table "fat_free_crm_facilities", force: :cascade do |t|
    t.string "facility_kind", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "status"
  end

  create_table "fat_free_crm_field_groups", id: :serial, force: :cascade do |t|
    t.string "name", limit: 64
    t.string "label", limit: 128
    t.integer "position"
    t.string "hint"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tag_id"
    t.string "klass_name", limit: 32
  end

  create_table "fat_free_crm_fields", id: :serial, force: :cascade do |t|
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
    t.index ["field_group_id"], name: "index_fat_free_crm_fields_on_field_group_id"
    t.index ["name"], name: "index_fat_free_crm_fields_on_name"
  end

  create_table "fat_free_crm_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fat_free_crm_groups_users", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id", "user_id"], name: "index_fat_free_crm_groups_users_on_group_id_and_user_id"
    t.index ["group_id"], name: "index_fat_free_crm_groups_users_on_group_id"
    t.index ["user_id"], name: "index_fat_free_crm_groups_users_on_user_id"
  end

  create_table "fat_free_crm_identifiers", force: :cascade do |t|
    t.string "identifiable_type"
    t.bigint "identifiable_id"
    t.string "item"
    t.string "kind"
    t.string "key"
    t.date "start_on"
    t.date "end_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifiable_type", "identifiable_id"], name: "identifiable_identifiers"
  end

  create_table "fat_free_crm_index_cases", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "assigned_to"
    t.string "access"
    t.string "source"
    t.string "background_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.bigint "opportunity_id"
    t.index ["opportunity_id"], name: "index_fat_free_crm_index_cases_on_opportunity_id"
    t.index ["user_id"], name: "index_fat_free_crm_index_cases_on_user_id"
  end

  create_table "fat_free_crm_leads", id: :serial, force: :cascade do |t|
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
    t.index ["assigned_to"], name: "index_fat_free_crm_leads_on_assigned_to"
    t.index ["user_id", "last_name", "deleted_at"], name: "leads_user_id_last_name_deleted_at", unique: true
  end

  create_table "fat_free_crm_levels", force: :cascade do |t|
    t.string "name"
    t.bigint "facility_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["facility_id"], name: "index_fat_free_crm_levels_on_facility_id"
  end

  create_table "fat_free_crm_lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_fat_free_crm_lists_on_user_id"
  end

  create_table "fat_free_crm_opportunities", id: :serial, force: :cascade do |t|
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
    t.index ["assigned_to"], name: "index_fat_free_crm_opportunities_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "id_name_deleted", unique: true
  end

  create_table "fat_free_crm_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "asset_type"
    t.integer "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "group_id"
    t.index ["asset_id", "asset_type"], name: "index_fat_free_crm_permissions_on_asset_id_and_asset_type"
    t.index ["group_id"], name: "index_fat_free_crm_permissions_on_group_id"
    t.index ["user_id"], name: "index_fat_free_crm_permissions_on_user_id"
  end

  create_table "fat_free_crm_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 32, default: "", null: false
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "name"], name: "index_fat_free_crm_preferences_on_user_id_and_name"
  end

  create_table "fat_free_crm_sections", force: :cascade do |t|
    t.string "name"
    t.bigint "level_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["level_id"], name: "index_fat_free_crm_sections_on_level_id"
  end

  create_table "fat_free_crm_sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_fat_free_crm_sessions_on_session_id"
    t.index ["updated_at"], name: "index_fat_free_crm_sessions_on_updated_at"
  end

  create_table "fat_free_crm_taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "taggable_type", limit: 50
    t.string "context", limit: 50
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context"], name: "taggings_idx", unique: true
  end

  create_table "fat_free_crm_tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_fat_free_crm_tags_on_name", unique: true
  end

  create_table "fat_free_crm_tasks", id: :serial, force: :cascade do |t|
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
    t.index ["assigned_to"], name: "index_fat_free_crm_tasks_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_fat_free_crm_tasks_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "fat_free_crm_units", force: :cascade do |t|
    t.string "name"
    t.string "kind"
    t.string "unitable_type"
    t.bigint "unitable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["unitable_type", "unitable_id"], name: "index_fat_free_crm_units_on_unitable_type_and_unitable_id"
  end

  create_table "fat_free_crm_users", id: :serial, force: :cascade do |t|
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
    t.index ["authentication_token"], name: "index_fat_free_crm_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_fat_free_crm_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_fat_free_crm_users_on_email"
    t.index ["remember_token"], name: "index_fat_free_crm_users_on_remember_token", unique: true
    t.index ["reset_password_token"], name: "index_fat_free_crm_users_on_reset_password_token", unique: true
    t.index ["username", "deleted_at"], name: "index_fat_free_crm_users_on_username_and_deleted_at", unique: true
  end

  create_table "fat_free_crm_versions", id: :serial, force: :cascade do |t|
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
    t.index ["created_at"], name: "index_fat_free_crm_versions_on_created_at"
    t.index ["item_type", "item_id"], name: "versions_item_type_id"
    t.index ["related_id", "related_type"], name: "index_fat_free_crm_versions_on_related_id_and_related_type"
    t.index ["transaction_id"], name: "index_fat_free_crm_versions_on_transaction_id"
    t.index ["whodunnit"], name: "index_fat_free_crm_versions_on_whodunnit"
  end

  create_table "fat_free_crm_zones", force: :cascade do |t|
    t.string "name"
    t.bigint "level_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["level_id"], name: "index_fat_free_crm_zones_on_level_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "name", limit: 32, default: "", null: false
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_settings_on_name"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
