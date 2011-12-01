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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111201030535) do

  create_table "account_aliases", :force => true do |t|
    t.integer  "account_id"
    t.integer  "destroyed_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "account_contacts", :force => true do |t|
    t.integer  "account_id"
    t.integer  "contact_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "account_opportunities", :force => true do |t|
    t.integer  "account_id"
    t.integer  "opportunity_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assigned_to"
    t.string   "name",            :limit => 128, :default => "",       :null => false
    t.string   "access",          :limit => 8,   :default => "Public"
    t.string   "website",         :limit => 64
    t.string   "toll_free_phone", :limit => 32
    t.string   "phone",           :limit => 32
    t.string   "fax",             :limit => 32
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",           :limit => 64
    t.string   "background_info"
    t.integer  "rating",                         :default => 0,        :null => false
    t.string   "category",        :limit => 32
    t.string   "edu_type"
  end

  add_index "accounts", ["assigned_to"], :name => "index_accounts_on_assigned_to"
  add_index "accounts", ["user_id", "name", "deleted_at"], :name => "index_accounts_on_user_id_and_name_and_deleted_at", :unique => true

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "action",       :limit => 32, :default => "created"
    t.string   "info",                       :default => ""
    t.boolean  "private",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "addresses", :force => true do |t|
    t.string   "street1"
    t.string   "street2"
    t.string   "city",             :limit => 64
    t.string   "state",            :limit => 64
    t.string   "zipcode",          :limit => 16
    t.string   "country",          :limit => 64
    t.string   "full_address"
    t.string   "address_type",     :limit => 16
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"

  create_table "application_accounts", :force => true do |t|
    t.string   "name"
    t.string   "api_key"
    t.string   "api_secret"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "avatars", :force => true do |t|
    t.integer  "user_id"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.integer  "image_file_size"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assigned_to"
    t.string   "name",                :limit => 64,                                :default => "",       :null => false
    t.string   "access",              :limit => 8,                                 :default => "Public"
    t.string   "status",              :limit => 64
    t.decimal  "budget",                            :precision => 12, :scale => 2
    t.integer  "target_leads"
    t.float    "target_conversion"
    t.decimal  "target_revenue",                    :precision => 12, :scale => 2
    t.integer  "leads_count"
    t.integer  "opportunities_count"
    t.decimal  "revenue",                           :precision => 12, :scale => 2
    t.date     "starts_on"
    t.date     "ends_on"
    t.text     "objectives"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info"
  end

  add_index "campaigns", ["assigned_to"], :name => "index_campaigns_on_assigned_to"
  add_index "campaigns", ["user_id", "name", "deleted_at"], :name => "index_campaigns_on_user_id_and_name_and_deleted_at", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.boolean  "private"
    t.string   "title",                          :default => ""
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",            :limit => 16, :default => "Expanded", :null => false
  end

  create_table "contact_aliases", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "destroyed_contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_opportunities", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "opportunity_id"
    t.string   "role",           :limit => 32
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lead_id"
    t.integer  "assigned_to"
    t.integer  "reports_to"
    t.string   "first_name",                                        :default => ""
    t.string   "last_name",                                         :default => ""
    t.string   "access",                             :limit => 8,   :default => "Public"
    t.string   "title",                              :limit => 64
    t.string   "department",                         :limit => 64
    t.string   "source",                             :limit => 32
    t.string   "email",                              :limit => 64
    t.string   "alt_email",                          :limit => 64
    t.string   "phone",                              :limit => 32
    t.string   "mobile",                             :limit => 32
    t.string   "fax",                                :limit => 32
    t.string   "blog",                               :limit => 128
    t.string   "linkedin",                           :limit => 128
    t.string   "facebook",                           :limit => 128
    t.string   "twitter",                            :limit => 128
    t.date     "born_on"
    t.boolean  "do_not_call",                                       :default => false,    :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info"
    t.string   "chinese_name"
    t.string   "preferred_name"
    t.string   "salutation"
    t.string   "octopus"
    t.string   "email_subscriptions"
    t.string   "skype",                              :limit => 128
    t.text     "languages_spoken"
    t.boolean  "ujhmkhyj"
    t.string   "age"
    t.text     "availability"
    t.string   "school_or_company"
    t.text     "skills"
    t.string   "resume"
    t.text     "other_information"
    t.string   "volunteering_type"
    t.text     "why_would_you_like_to_volunteer"
    t.text     "how_did_you_hear_about_crossroads"
    t.text     "interested_in_doing"
    t.text     "interests"
    t.date     "tour_date"
    t.text     "service_certificates"
    t.date     "seventy_hour_certificate"
    t.date     "one_hundred_forty_hour_certificate"
    t.date     "arrival_date"
    t.date     "departure_date"
    t.string   "length_of_stay"
    t.string   "goto_person"
  end

  add_index "contacts", ["assigned_to"], :name => "index_contacts_on_assigned_to"
  add_index "contacts", ["user_id", "last_name", "deleted_at"], :name => "index_contacts_on_user_id_and_last_name_and_deleted_at", :unique => true

  create_table "customfields", :force => true do |t|
    t.string   "uuid",             :limit => 36
    t.integer  "user_id"
    t.integer  "tag_id"
    t.string   "field_name",       :limit => 64
    t.string   "field_type",       :limit => 32
    t.string   "field_label",      :limit => 64
    t.string   "table_name",       :limit => 32
    t.integer  "display_sequence"
    t.integer  "display_block"
    t.integer  "display_width"
    t.integer  "max_size"
    t.boolean  "required"
    t.boolean  "disabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "form_field_type"
    t.string   "field_info"
    t.text     "select_options"
    t.integer  "position"
  end

  add_index "customfields", ["field_name"], :name => "index_customfields_on_field_name"

  create_table "emails", :force => true do |t|
    t.string   "imap_message_id",                                       :null => false
    t.integer  "user_id"
    t.integer  "mediator_id"
    t.string   "mediator_type"
    t.string   "sent_from",                                             :null => false
    t.string   "sent_to",                                               :null => false
    t.string   "cc"
    t.string   "bcc"
    t.string   "subject"
    t.text     "body"
    t.text     "header"
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",           :limit => 16, :default => "Expanded", :null => false
  end

  add_index "emails", ["mediator_id", "mediator_type"], :name => "index_emails_on_mediator_id_and_mediator_type"

  create_table "field_groups", :force => true do |t|
    t.string   "name",       :limit => 64
    t.string   "label",      :limit => 128
    t.integer  "position"
    t.string   "hint"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_id"
    t.string   "klass_name", :limit => 32
  end

  create_table "fields", :force => true do |t|
    t.string   "type"
    t.integer  "field_group_id"
    t.integer  "position"
    t.string   "name",           :limit => 64
    t.string   "label",          :limit => 128
    t.string   "hint"
    t.string   "placeholder"
    t.string   "as",             :limit => 32
    t.text     "collection"
    t.boolean  "disabled"
    t.boolean  "required"
    t.integer  "maxlength"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fields", ["field_group_id"], :name => "index_fields_on_field_group_id"
  add_index "fields", ["name"], :name => "index_fields_on_name"

  create_table "leads", :force => true do |t|
    t.integer  "user_id"
    t.integer  "campaign_id"
    t.integer  "assigned_to"
    t.string   "first_name",      :limit => 64,  :default => "",       :null => false
    t.string   "last_name",       :limit => 64,  :default => "",       :null => false
    t.string   "access",          :limit => 8,   :default => "Public"
    t.string   "title",           :limit => 64
    t.string   "company",         :limit => 64
    t.string   "source",          :limit => 32
    t.string   "status",          :limit => 32
    t.string   "referred_by",     :limit => 64
    t.string   "email",           :limit => 64
    t.string   "alt_email",       :limit => 64
    t.string   "phone",           :limit => 32
    t.string   "mobile",          :limit => 32
    t.string   "blog",            :limit => 128
    t.string   "linkedin",        :limit => 128
    t.string   "facebook",        :limit => 128
    t.string   "twitter",         :limit => 128
    t.integer  "rating",                         :default => 0,        :null => false
    t.boolean  "do_not_call",                    :default => false,    :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info"
    t.string   "skype",           :limit => 128
  end

  add_index "leads", ["assigned_to"], :name => "index_leads_on_assigned_to"
  add_index "leads", ["user_id", "last_name", "deleted_at"], :name => "index_leads_on_user_id_and_last_name_and_deleted_at", :unique => true

  create_table "opportunities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "campaign_id"
    t.integer  "assigned_to"
    t.string   "name",                :limit => 64,                                :default => "",       :null => false
    t.string   "access",              :limit => 8,                                 :default => "Public"
    t.string   "source",              :limit => 32
    t.string   "stage",               :limit => 32
    t.integer  "probability"
    t.decimal  "amount",                            :precision => 12, :scale => 2
    t.decimal  "discount",                          :precision => 12, :scale => 2
    t.date     "closes_on"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info"
    t.boolean  "follow_up_permitted"
    t.string   "main_activity"
    t.string   "swd_client_name"
    t.string   "swd_reference"
    t.date     "collect_date"
    t.string   "swd_client_id"
  end

  add_index "opportunities", ["assigned_to"], :name => "index_opportunities_on_assigned_to"
  add_index "opportunities", ["user_id", "name", "deleted_at"], :name => "index_opportunities_on_user_id_and_name_and_deleted_at", :unique => true

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "asset_id"
    t.string   "asset_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["asset_id", "asset_type"], :name => "index_permissions_on_asset_id_and_asset_type"
  add_index "permissions", ["user_id"], :name => "index_permissions_on_user_id"

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",       :limit => 32, :default => "", :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["user_id", "name"], :name => "index_preferences_on_user_id_and_name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "name",          :limit => 32, :default => "", :null => false
    t.text     "value"
    t.text     "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"

  create_table "tag1s", :force => true do |t|
    t.integer "customizable_id"
    t.string  "customizable_type"
    t.string  "main_activity"
    t.boolean "follow_up_permitted"
    t.string  "swd_client_id"
    t.string  "swd_reference"
    t.string  "swd_client_name"
    t.date    "collect_date"
    t.string  "im_a_label"
  end

  create_table "tag2s", :force => true do |t|
    t.integer "customizable_id"
    t.string  "customizable_type"
    t.text    "description"
  end

  create_table "tag3s", :force => true do |t|
    t.integer "customizable_id"
    t.string  "customizable_type"
    t.text    "description"
    t.text    "registration"
  end

  create_table "tag4s", :force => true do |t|
    t.integer "customizable_id"
    t.string  "customizable_type"
    t.boolean "receive_email"
    t.string  "languages_spoken"
    t.date    "tour_date"
    t.string  "availability"
    t.string  "school_or_company"
    t.text    "skills"
    t.string  "resume"
    t.text    "interests"
    t.string  "volunteering_type"
    t.text    "why_would_you_like_to_volunteer"
    t.text    "how_did_you_hear_about_crossroads"
    t.text    "interested_in_doing"
    t.text    "other_information"
    t.text    "service_certificates"
    t.date    "seventy_hour_certificate"
    t.date    "one_hundred_forty_hour_certificate"
    t.text    "age"
    t.boolean "ujhmkhyj"
  end

  create_table "tag5s", :force => true do |t|
    t.integer "customizable_id"
    t.string  "customizable_type"
    t.string  "edu_type"
  end

  create_table "tag9s", :force => true do |t|
    t.integer "customizable_id"
    t.string  "customizable_type"
    t.date    "arrival_date"
    t.date    "departure_date"
    t.string  "length_of_stay"
    t.string  "goto_person"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "taggable_type"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assigned_to"
    t.integer  "completed_by"
    t.string   "name",                          :default => "", :null => false
    t.integer  "asset_id"
    t.string   "asset_type"
    t.string   "priority",        :limit => 32
    t.string   "category",        :limit => 32
    t.string   "bucket",          :limit => 32
    t.datetime "due_at"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_info"
  end

  add_index "tasks", ["assigned_to"], :name => "index_tasks_on_assigned_to"
  add_index "tasks", ["user_id", "name", "deleted_at"], :name => "index_tasks_on_user_id_and_name_and_deleted_at", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username",            :limit => 32, :default => "",    :null => false
    t.string   "email",               :limit => 64, :default => "",    :null => false
    t.string   "first_name",          :limit => 32
    t.string   "last_name",           :limit => 32
    t.string   "title",               :limit => 64
    t.string   "company",             :limit => 64
    t.string   "alt_email",           :limit => 64
    t.string   "phone",               :limit => 32
    t.string   "mobile",              :limit => 32
    t.string   "aim",                 :limit => 32
    t.string   "yahoo",               :limit => 32
    t.string   "google",              :limit => 32
    t.string   "skype",               :limit => 32
    t.string   "password_hash",                     :default => "",    :null => false
    t.string   "password_salt",                     :default => "",    :null => false
    t.string   "persistence_token",                 :default => "",    :null => false
    t.string   "perishable_token",                  :default => "",    :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.integer  "login_count",                       :default => 0,     :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                             :default => false, :null => false
    t.datetime "suspended_at"
    t.string   "single_access_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_remember_token"
  add_index "users", ["username", "deleted_at"], :name => "index_users_on_username_and_deleted_at", :unique => true

end

