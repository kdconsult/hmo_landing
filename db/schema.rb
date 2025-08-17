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

ActiveRecord::Schema[8.0].define(version: 2025_08_17_142737) do
  create_table "api_idempotency_keys", force: :cascade do |t|
    t.string "key"
    t.string "endpoint"
    t.string "request_hash"
    t.json "response_body"
    t.integer "response_status"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint", "request_hash"], name: "index_api_idempotency_keys_on_endpoint_and_request_hash"
    t.index ["expires_at"], name: "index_api_idempotency_keys_on_expires_at"
    t.index ["key"], name: "index_api_idempotency_keys_on_key", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "body"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_campaigns_on_slug", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "event_type", null: false
    t.integer "campaign_id"
    t.integer "landing_page_id"
    t.integer "lead_id"
    t.json "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "landing_page_id", "event_type", "created_at"], name: "index_events_on_dims_and_time"
    t.index ["campaign_id"], name: "index_events_on_campaign_id"
    t.index ["landing_page_id"], name: "index_events_on_landing_page_id"
    t.index ["lead_id"], name: "index_events_on_lead_id"
  end

  create_table "idempotency_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "endpoint", null: false
    t.string "request_hash", null: false
    t.json "response_body"
    t.integer "response_status"
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint", "request_hash"], name: "index_idempotency_keys_on_endpoint_and_request_hash"
    t.index ["expires_at"], name: "index_idempotency_keys_on_expires_at"
    t.index ["key"], name: "index_idempotency_keys_on_key", unique: true
  end

  create_table "landing_pages", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "slug", null: false
    t.string "headline"
    t.string "subheadline"
    t.text "body"
    t.string "primary_cta_label"
    t.string "primary_cta_url"
    t.json "schema", default: {}, null: false
    t.integer "schema_version", default: 1, null: false
    t.string "template", default: "default", null: false
    t.string "status", default: "draft", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "status"], name: "index_landing_pages_on_campaign_id_and_status"
    t.index ["campaign_id"], name: "index_landing_pages_on_campaign_id"
    t.index ["slug"], name: "index_landing_pages_on_slug", unique: true
  end

  create_table "leads", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "landing_page_id", null: false
    t.string "public_id", null: false
    t.string "name", null: false
    t.string "email_ciphertext", null: false
    t.string "phone_ciphertext", null: false
    t.string "email_bidx"
    t.string "phone_bidx"
    t.boolean "marketing_consent", default: false, null: false
    t.datetime "consented_at"
    t.string "consent_source"
    t.string "privacy_policy_version"
    t.json "data", default: {}, null: false
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.string "utm_term"
    t.string "utm_content"
    t.string "gclid"
    t.string "fbclid"
    t.string "msclkid"
    t.string "referrer_url"
    t.string "landing_url"
    t.string "user_agent"
    t.string "ip_address"
    t.string "referral_code"
    t.bigint "referred_by_lead_id"
    t.string "idempotency_key"
    t.integer "schema_version_at_submit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "landing_page_id", "created_at"], name: "index_leads_on_dims_and_time"
    t.index ["campaign_id", "referral_code"], name: "index_leads_on_campaign_id_and_referral_code", unique: true
    t.index ["campaign_id"], name: "index_leads_on_campaign_id"
    t.index ["email_bidx"], name: "index_leads_on_email_bidx"
    t.index ["landing_page_id"], name: "index_leads_on_landing_page_id"
    t.index ["phone_bidx"], name: "index_leads_on_phone_bidx"
    t.index ["public_id"], name: "index_leads_on_public_id", unique: true
  end

  add_foreign_key "events", "campaigns"
  add_foreign_key "events", "landing_pages"
  add_foreign_key "events", "leads"
  add_foreign_key "landing_pages", "campaigns"
  add_foreign_key "leads", "campaigns"
  add_foreign_key "leads", "landing_pages"
  add_foreign_key "leads", "leads", column: "referred_by_lead_id", on_delete: :nullify
end
