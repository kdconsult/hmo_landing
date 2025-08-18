class EnsureLeadsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :leads, if_not_exists: true do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :landing_page, null: false, foreign_key: true

      t.string :public_id, null: false
      t.string :name, null: false
      t.string :email_ciphertext, null: false
      t.string :phone_ciphertext, null: false
      t.string :email_bidx
      t.string :phone_bidx

      t.boolean :marketing_consent, null: false, default: false
      t.datetime :consented_at
      t.string :consent_source
      t.string :privacy_policy_version

      t.json :data, null: false, default: {}

      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_term
      t.string :utm_content

      t.string :gclid
      t.string :fbclid
      t.string :msclkid

      t.string :referrer_url
      t.string :landing_url
      t.string :user_agent
      t.string :ip_address

      t.string :referral_code
      t.bigint :referred_by_lead_id

      t.string :idempotency_key
      t.integer :schema_version_at_submit

      t.timestamps
    end

    # Indexes
    add_index :leads, :public_id, unique: true, if_not_exists: true
    add_index :leads, :email_bidx, if_not_exists: true
    add_index :leads, :phone_bidx, if_not_exists: true
    add_index :leads, :campaign_id, if_not_exists: true
    add_index :leads, :landing_page_id, if_not_exists: true
    add_index :leads, [:campaign_id, :landing_page_id, :created_at], name: "index_leads_on_dims_and_time", if_not_exists: true
    add_index :leads, [:campaign_id, :referral_code], unique: true, name: "index_leads_on_campaign_id_and_referral_code", if_not_exists: true

    # Self-referential FK for referrals
    add_foreign_key :leads, :leads, column: :referred_by_lead_id, on_delete: :nullify if foreign_key_absent?(:leads, :referred_by_lead_id)
  end

  private

  def foreign_key_absent?(from_table, column)
    fk = foreign_keys(from_table).find { |f| f.options[:column].to_s == column.to_s }
    fk.nil?
  end
end
