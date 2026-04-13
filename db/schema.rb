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

ActiveRecord::Schema[7.1].define(version: 2026_04_13_041448) do
  create_table "account_contacts", force: :cascade do |t|
    t.integer "account_id"
    t.integer "contact_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["account_id", "contact_id"], name: "index_account_contacts_on_account_id_and_contact_id"
  end

  create_table "account_opportunities", force: :cascade do |t|
    t.integer "account_id"
    t.integer "opportunity_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["account_id", "opportunity_id"], name: "index_account_opportunities_on_account_id_and_opportunity_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "assigned_to"
    t.string "name", limit: 64, default: "", null: false
    t.string "access", limit: 8, default: "Public"
    t.string "website", limit: 64
    t.string "toll_free_phone", limit: 32
    t.string "phone", limit: 32
    t.string "fax", limit: 32
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "email", limit: 254
    t.string "background_info"
    t.integer "rating", default: 0, null: false
    t.string "category", limit: 32
    t.text "subscribed_users"
    t.integer "contacts_count", default: 0
    t.integer "opportunities_count", default: 0
    t.string "wikidata_id"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "blog"
    t.string "linkedin"
    t.string "facebook"
    t.string "twitter"
    t.string "bluesky"
    t.string "instagram"
    t.string "mastodon"
    t.index ["assigned_to"], name: "index_accounts_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_accounts_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "user_id"
    t.string "subject_type"
    t.integer "subject_id"
    t.string "action", limit: 32, default: "created"
    t.string "info", default: ""
    t.boolean "private", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "addresses", force: :cascade do |t|
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type"
  end

  create_table "avatars", force: :cascade do |t|
    t.integer "user_id"
    t.string "entity_type"
    t.integer "entity_id"
    t.integer "image_file_size"
    t.string "image_file_name"
    t.string "image_content_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "campaigns", force: :cascade do |t|
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
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "background_info"
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_campaigns_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_campaigns_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.boolean "private"
    t.string "title", default: ""
    t.text "comment"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "state", limit: 16, default: "Expanded", null: false
  end

  create_table "contact_opportunities", force: :cascade do |t|
    t.integer "contact_id"
    t.integer "opportunity_id"
    t.string "role", limit: 32
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["contact_id", "opportunity_id"], name: "index_contact_opportunities_on_contact_id_and_opportunity_id"
  end

  create_table "contacts", force: :cascade do |t|
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
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "background_info"
    t.text "subscribed_users"
    t.string "zoom", limit: 128
    t.string "teams", limit: 128
    t.string "signal", limit: 128
    t.string "instagram", limit: 128
    t.string "mastodon", limit: 128
    t.string "bluesky", limit: 128
    t.index ["assigned_to"], name: "index_contacts_on_assigned_to"
    t.index ["user_id", "last_name", "deleted_at"], name: "id_last_name_deleted", unique: true
  end

  create_table "emails", force: :cascade do |t|
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
    t.datetime "sent_at", precision: nil
    t.datetime "received_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "state", limit: 16, default: "Expanded", null: false
    t.index ["mediator_id", "mediator_type"], name: "index_emails_on_mediator_id_and_mediator_type"
  end

  create_table "field_groups", force: :cascade do |t|
    t.string "name", limit: 64
    t.string "label", limit: 128
    t.integer "position"
    t.string "hint"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "tag_id"
    t.string "klass_name", limit: 32
  end

  create_table "fields", force: :cascade do |t|
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
    t.integer "maxlength", limit: 4
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "pair_id"
    t.text "settings"
    t.integer "minlength", limit: 4, default: 0
    t.string "pattern"
    t.string "autofocus"
    t.string "autocomplete"
    t.string "list"
    t.string "multiple"
    t.string "title"
    t.index ["field_group_id"], name: "index_fields_on_field_group_id"
    t.index ["name"], name: "index_fields_on_name"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "leads", force: :cascade do |t|
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
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "background_info"
    t.text "subscribed_users"
    t.string "zoom", limit: 128
    t.string "teams", limit: 128
    t.string "signal", limit: 128
    t.string "instagram", limit: 128
    t.string "mastodon", limit: 128
    t.string "bluesky", limit: 128
    t.index ["assigned_to"], name: "index_leads_on_assigned_to"
    t.index ["user_id", "last_name", "deleted_at"], name: "index_leads_on_user_id_and_last_name_and_deleted_at", unique: true
  end

  create_table "lists", force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "opportunities", force: :cascade do |t|
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
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "background_info"
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_opportunities_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "id_name_deleted", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.integer "user_id"
    t.string "asset_type"
    t.integer "asset_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "group_id"
    t.index ["asset_id", "asset_type"], name: "index_permissions_on_asset_id_and_asset_type"
    t.index ["group_id"], name: "index_permissions_on_group_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "preferences", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 32, default: "", null: false
    t.text "value"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id", "name"], name: "index_preferences_on_user_id_and_name"
  end

  create_table "research_tools", force: :cascade do |t|
    t.string "name"
    t.string "url_template"
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name", limit: 32, default: "", null: false
    t.text "value"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_settings_on_name"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "taggable_type", limit: 50
    t.string "context", limit: 50
    t.datetime "created_at", precision: nil
    t.index ["tag_id", "taggable_id", "taggable_type", "context"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "assigned_to"
    t.integer "completed_by"
    t.string "name", default: "", null: false
    t.string "asset_type"
    t.integer "asset_id"
    t.string "priority", limit: 32
    t.string "category", limit: 32
    t.string "bucket", limit: 32
    t.datetime "due_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "background_info"
    t.text "subscribed_users"
    t.index ["assigned_to"], name: "index_tasks_on_assigned_to"
    t.index ["user_id", "name", "deleted_at"], name: "index_tasks_on_user_id_and_name_and_deleted_at", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 32, default: "", null: false
    t.string "email", limit: 254
    t.string "first_name", limit: 32
    t.string "last_name", limit: 32
    t.string "title", limit: 64
    t.string "company", limit: 64
    t.string "alt_email", limit: 254
    t.string "phone", limit: 32
    t.string "mobile", limit: 32
    t.string "google", limit: 32
    t.string "encrypted_password", default: "", null: false
    t.string "password_salt", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "current_sign_in_ip"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "admin", default: false, null: false
    t.datetime "suspended_at", precision: nil
    t.string "unconfirmed_email", limit: 254
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.string "remember_token"
    t.datetime "remember_created_at", precision: nil
    t.string "authentication_token"
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean "subscribe_to_comment_replies", default: true, null: false
    t.boolean "receive_assigned_notifications", default: true, null: false
    t.string "zoom", limit: 128
    t.string "teams", limit: 128
    t.string "signal", limit: 128
    t.string "instagram", limit: 128
    t.string "facebook", limit: 128
    t.string "mastodon", limit: 128
    t.string "bluesky", limit: 128
    t.string "twitter", limit: 128
    t.string "linkedin", limit: 128
    t.string "blog", limit: 128
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username", "deleted_at"], name: "index_users_on_username_and_deleted_at", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", limit: 512
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
