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

ActiveRecord::Schema.define(version: 2018_11_20_152842) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "title"
    t.text "description"
    t.uuid "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ews_id"
    t.index ["creator_id"], name: "index_activities_on_creator_id"
  end

  create_table "activities_contacts", id: false, force: :cascade do |t|
    t.uuid "activity_id"
    t.uuid "contact_id"
    t.index ["activity_id", "contact_id"], name: "by_activity_and_contact", unique: true
    t.index ["activity_id"], name: "index_activities_contacts_on_activity_id"
    t.index ["contact_id"], name: "index_activities_contacts_on_contact_id"
  end

  create_table "activities_mandates", id: false, force: :cascade do |t|
    t.uuid "activity_id"
    t.uuid "mandate_id"
    t.index ["activity_id", "mandate_id"], name: "by_activity_and_mandate", unique: true
    t.index ["activity_id"], name: "index_activities_mandates_on_activity_id"
    t.index ["mandate_id"], name: "index_activities_mandates_on_mandate_id"
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "owner_id", null: false
    t.string "postal_code"
    t.string "city"
    t.string "country"
    t.string "addition"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.string "street_and_number"
    t.string "owner_type", null: false
    t.index ["owner_type", "owner_id"], name: "index_addresses_on_owner_type_and_owner_id"
  end

  create_table "bank_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "account_type"
    t.string "owner_name"
    t.string "bank_account_number"
    t.string "bank_routing_number"
    t.string "iban"
    t.string "bic"
    t.string "currency"
    t.uuid "owner_id", null: false
    t.uuid "bank_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_type", null: false
    t.index ["bank_id"], name: "index_bank_accounts_on_bank_id"
    t.index ["owner_type", "owner_id"], name: "index_bank_accounts_on_owner_type_and_owner_id"
  end

  create_table "compliance_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "wphg_classification"
    t.string "kagb_classification"
    t.boolean "politically_exposed", default: false, null: false
    t.string "occupation_role"
    t.string "occupation_title"
    t.integer "retirement_age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "contact_id"
    t.index ["contact_id"], name: "index_compliance_details_on_contact_id"
  end

  create_table "contact_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "category"
    t.string "value"
    t.boolean "primary", default: false, null: false
    t.uuid "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_contact_details_on_contact_id"
  end

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.text "comment"
    t.string "gender"
    t.string "nobility_title"
    t.string "professional_title"
    t.string "maiden_name"
    t.date "date_of_birth"
    t.date "date_of_death"
    t.string "nationality"
    t.string "organization_name"
    t.string "organization_type"
    t.string "organization_category"
    t.string "organization_industry"
    t.string "commercial_register_number"
    t.string "commercial_register_office"
    t.uuid "legal_address_id"
    t.uuid "primary_contact_address_id"
    t.integer "import_id"
    t.string "place_of_birth"
    t.index ["legal_address_id"], name: "index_contacts_on_legal_address_id"
    t.index ["primary_contact_address_id"], name: "index_contacts_on_primary_contact_address_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.date "valid_from"
    t.date "valid_to"
    t.uuid "uploader_id", null: false
    t.string "owner_type", null: false
    t.uuid "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["owner_type", "owner_id"], name: "index_documents_on_owner_type_and_owner_id"
    t.index ["uploader_id"], name: "index_documents_on_uploader_id"
  end

  create_table "foreign_tax_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tax_number"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "tax_detail_id"
    t.index ["tax_detail_id"], name: "index_foreign_tax_numbers_on_tax_detail_id"
  end

  create_table "funds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "duration"
    t.integer "duration_extension"
    t.string "aasm_state", null: false
    t.string "asset_class"
    t.string "commercial_register_number"
    t.string "commercial_register_office"
    t.string "currency"
    t.string "name", null: false
    t.string "psplus_asset_id"
    t.string "region"
    t.string "strategy"
    t.text "comment"
    t.uuid "capital_management_company_id"
    t.uuid "legal_address_id"
    t.uuid "primary_contact_address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "issuing_year"
    t.index ["capital_management_company_id"], name: "index_funds_on_capital_management_company_id"
    t.index ["legal_address_id"], name: "index_funds_on_legal_address_id"
    t.index ["primary_contact_address_id"], name: "index_funds_on_primary_contact_address_id"
  end

  create_table "inter_person_relationships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "role", null: false
    t.uuid "target_person_id", null: false
    t.uuid "source_person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_person_id"], name: "index_inter_person_relationships_on_source_person_id"
    t.index ["target_person_id"], name: "index_inter_person_relationships_on_target_person_id"
  end

  create_table "mandate_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "group_type"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mandate_groups_mandates", id: false, force: :cascade do |t|
    t.uuid "mandate_id"
    t.uuid "mandate_group_id"
    t.index ["mandate_group_id", "mandate_id"], name: "by_mandate_group_and_mandate", unique: true
    t.index ["mandate_group_id"], name: "index_mandate_groups_mandates_on_mandate_group_id"
    t.index ["mandate_id"], name: "index_mandate_groups_mandates_on_mandate_id"
  end

  create_table "mandate_groups_user_groups", id: false, force: :cascade do |t|
    t.uuid "user_group_id"
    t.uuid "mandate_group_id"
    t.index ["mandate_group_id", "user_group_id"], name: "by_mandate_group_and_user_group", unique: true
    t.index ["mandate_group_id"], name: "index_mandate_groups_user_groups_on_mandate_group_id"
    t.index ["user_group_id"], name: "index_mandate_groups_user_groups_on_user_group_id"
  end

  create_table "mandate_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "member_type"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "contact_id"
    t.uuid "mandate_id"
    t.index ["contact_id"], name: "index_mandate_members_on_contact_id"
    t.index ["mandate_id"], name: "index_mandate_members_on_mandate_id"
  end

  create_table "mandates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aasm_state"
    t.string "category"
    t.text "comment"
    t.date "valid_from"
    t.date "valid_to"
    t.string "datev_creditor_id"
    t.string "datev_debitor_id"
    t.string "mandate_number"
    t.string "psplus_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "primary_consultant_id"
    t.uuid "secondary_consultant_id"
    t.uuid "assistant_id"
    t.uuid "bookkeeper_id"
    t.integer "import_id"
    t.string "default_currency"
    t.decimal "prospect_assets_under_management", precision: 20, scale: 10
    t.decimal "prospect_fees_percentage", precision: 20, scale: 10
    t.decimal "prospect_fees_fixed_amount", precision: 20, scale: 10
    t.decimal "prospect_fees_min_amount", precision: 20, scale: 10
    t.index ["assistant_id"], name: "index_mandates_on_assistant_id"
    t.index ["bookkeeper_id"], name: "index_mandates_on_bookkeeper_id"
    t.index ["primary_consultant_id"], name: "index_mandates_on_primary_consultant_id"
    t.index ["secondary_consultant_id"], name: "index_mandates_on_secondary_consultant_id"
  end

  create_table "organization_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "role", null: false
    t.uuid "organization_id", null: false
    t.uuid "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_organization_members_on_contact_id"
    t.index ["organization_id"], name: "index_organization_members_on_organization_id"
  end

  create_table "tax_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "de_tax_number"
    t.string "de_tax_id"
    t.string "de_tax_office"
    t.boolean "de_retirement_insurance", default: false, null: false
    t.boolean "de_unemployment_insurance", default: false, null: false
    t.boolean "de_health_insurance", default: false, null: false
    t.boolean "de_church_tax", default: false, null: false
    t.string "us_tax_number"
    t.string "us_tax_form"
    t.string "us_fatca_status"
    t.boolean "common_reporting_standard", default: false, null: false
    t.string "eu_vat_number"
    t.string "legal_entity_identifier"
    t.boolean "transparency_register", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "contact_id"
    t.index ["contact_id"], name: "index_tax_details_on_contact_id"
  end

  create_table "user_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.string "roles", default: [], array: true
  end

  create_table "user_groups_users", id: false, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "user_group_id"
    t.index ["user_group_id", "user_id"], name: "by_user_group_and_user", unique: true
    t.index ["user_group_id"], name: "index_user_groups_users_on_user_group_id"
    t.index ["user_id"], name: "index_user_groups_users_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.text "comment"
    t.uuid "contact_id"
    t.string "ews_user_id"
    t.datetime "deactivated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["contact_id"], name: "index_users_on_contact_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.uuid "whodunnit"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.string "parent_item_type"
    t.uuid "parent_item_id"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "activities", "users", column: "creator_id"
  add_foreign_key "activities_contacts", "activities"
  add_foreign_key "activities_contacts", "contacts"
  add_foreign_key "activities_mandates", "activities"
  add_foreign_key "activities_mandates", "mandates"
  add_foreign_key "bank_accounts", "contacts", column: "bank_id"
  add_foreign_key "compliance_details", "contacts"
  add_foreign_key "contact_details", "contacts"
  add_foreign_key "contacts", "addresses", column: "legal_address_id"
  add_foreign_key "contacts", "addresses", column: "primary_contact_address_id"
  add_foreign_key "documents", "users", column: "uploader_id"
  add_foreign_key "foreign_tax_numbers", "tax_details"
  add_foreign_key "funds", "addresses", column: "legal_address_id"
  add_foreign_key "funds", "addresses", column: "primary_contact_address_id"
  add_foreign_key "funds", "contacts", column: "capital_management_company_id"
  add_foreign_key "inter_person_relationships", "contacts", column: "source_person_id"
  add_foreign_key "inter_person_relationships", "contacts", column: "target_person_id"
  add_foreign_key "mandate_groups_mandates", "mandate_groups"
  add_foreign_key "mandate_groups_mandates", "mandates"
  add_foreign_key "mandate_groups_user_groups", "mandate_groups"
  add_foreign_key "mandate_groups_user_groups", "user_groups"
  add_foreign_key "mandate_members", "contacts"
  add_foreign_key "mandate_members", "mandates"
  add_foreign_key "mandates", "contacts", column: "assistant_id"
  add_foreign_key "mandates", "contacts", column: "bookkeeper_id"
  add_foreign_key "mandates", "contacts", column: "primary_consultant_id"
  add_foreign_key "mandates", "contacts", column: "secondary_consultant_id"
  add_foreign_key "organization_members", "contacts", column: "organization_id"
  add_foreign_key "tax_details", "contacts"
  add_foreign_key "user_groups_users", "user_groups"
  add_foreign_key "user_groups_users", "users"
  add_foreign_key "users", "contacts"
end
