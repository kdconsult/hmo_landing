require "digest"
require "base64"

class Lead < ApplicationRecord
  belongs_to :campaign
  belongs_to :landing_page

  validates :public_id, presence: true
  validates :name, presence: true
  validates :email_ciphertext, presence: true
  validates :phone_ciphertext, presence: true
  validates :marketing_consent, inclusion: { in: [ true, false ] }

  before_validation :ensure_public_id
  before_validation :normalize_email_and_phone_and_compute_blind_indexes
  validate :email_uniqueness_per_campaign, unless: -> { campaign&.allow_duplicate_leads }
  validate :phone_uniqueness_per_campaign, unless: -> { campaign&.allow_duplicate_leads }
  after_commit :send_creation_emails, on: :create

  # Public plaintext accessors for marketing workflows
  def email
    email_plaintext
  end

  def email=(value)
    self[:email_ciphertext] = value
  end

  def phone
    phone_plaintext
  end

  def phone=(value)
    self[:phone_ciphertext] = value
  end

  private

  def ensure_public_id
    self.public_id ||= SecureRandom.uuid
  end

  # Normalize plaintext values and compute blind indexes for deterministic lookups
  def normalize_email_and_phone_and_compute_blind_indexes
    # Email normalization + blind index + encryption-at-rest
    if self.email_ciphertext.present?
      plaintext_email = email_plaintext
      normalized_email = plaintext_email.to_s.strip.downcase
      self.email_bidx = compute_email_bidx(normalized_email)
      self.email_ciphertext = encrypt_value(normalized_email)
    else
      self.email_bidx = nil
    end

    # Phone normalization + blind index + encryption-at-rest
    if self.phone_ciphertext.present?
      plaintext_phone = phone_plaintext
      parsed = Phonelib.parse(plaintext_phone, "BG")
      if parsed.valid?
        normalized_phone = parsed.e164
        self.phone_bidx = compute_phone_bidx(normalized_phone)
        self.phone_ciphertext = encrypt_value(normalized_phone)
      else
        errors.add(:phone_ciphertext, "is not a valid phone number")
        self.phone_bidx = nil
      end
    else
      self.phone_bidx = nil
    end
  end

  def email_uniqueness_per_campaign
    return if email_bidx.blank? || campaign_id.blank?
    if Lead.where(campaign_id: campaign_id, email_bidx: email_bidx).where.not(id: id).exists?
      errors.add(:email_ciphertext, "A lead with this email already exists for this campaign.")
    end
  end

  def phone_uniqueness_per_campaign
    return if phone_bidx.blank? || campaign_id.blank?
    if Lead.where(campaign_id: campaign_id, phone_bidx: phone_bidx).where.not(id: id).exists?
      errors.add(:phone_ciphertext, "A lead with this phone number already exists for this campaign.")
    end
  end

  # Blind index helpers
  def compute_email_bidx(value)
    return nil if value.blank?
    pepper = ENV["LEAD_EMAIL_BIDX_PEPPER"].presence || credentials_bidx_pepper(:email) || "dev-insecure-email-pepper"
    Digest::SHA256.hexdigest([ pepper, value ].join("--"))
  end

  def compute_phone_bidx(value)
    return nil if value.blank?
    pepper = ENV["LEAD_PHONE_BIDX_PEPPER"].presence || credentials_bidx_pepper(:phone) || "dev-insecure-phone-pepper"
    Digest::SHA256.hexdigest([ pepper, value ].join("--"))
  end

  def credentials_bidx_pepper(kind)
    # Supports credentials structure: lead_bidx_pepper: { email: "...", phone: "..." }
    Rails.application.credentials.dig(:lead_bidx_pepper, kind) if defined?(Rails)
  rescue StandardError
    nil
  end

  # Encryption helpers (AES-GCM via ActiveSupport::MessageEncryptor)
  def email_plaintext
    decrypt_value(self[:email_ciphertext])
  end

  def phone_plaintext
    decrypt_value(self[:phone_ciphertext])
  end

  def encrypt_value(value)
    return nil if value.blank?
    encryptor = build_encryptor
    ciphertext = encryptor.encrypt_and_sign(value)
    "enc--" + Base64.strict_encode64(ciphertext)
  end

  def decrypt_value(value)
    return nil if value.blank?
    str = value.to_s
    if str.start_with?("enc--")
      begin
        encrypted_bytes = Base64.decode64(str.delete_prefix("enc--"))
        encryptor = build_encryptor
        encryptor.decrypt_and_verify(encrypted_bytes)
      rescue StandardError
        nil
      end
    else
      # Allow legacy/plaintext values
      str
    end
  end

  def build_encryptor
    # Expect a 32-byte key in hex (64 chars). Use insecure default in dev/test.
    hex_key = ENV["LEAD_ENCRYPTION_KEY_HEX"].presence || credentials_bidx_pepper(:encryption_key_hex) || (Rails.env.production? ? nil : ("0" * 64))
    raise "LEAD_ENCRYPTION_KEY_HEX not configured" if hex_key.blank?
    secret = [ hex_key ].pack("H*")
    ActiveSupport::MessageEncryptor.new(secret, cipher: "aes-256-gcm")
  end

  def send_creation_emails
    # Deliver emails asynchronously to avoid blocking request threads
    LeadMailer.admin_new_lead(self).deliver_later
    # Only send confirmation if we have a decryptable email
    if email.present?
      LeadMailer.lead_confirmation(self).deliver_later
    end
  rescue StandardError => e
    Rails.logger.error("Failed to enqueue lead emails for Lead##{id}: #{e.class}: #{e.message}") if defined?(Rails)
  end
end
