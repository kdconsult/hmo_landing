class Lead < ApplicationRecord
  belongs_to :campaign
  belongs_to :landing_page

  validates :public_id, presence: true
  validates :name, presence: true
  validates :email_ciphertext, presence: true
  validates :phone_ciphertext, presence: true
  validates :marketing_consent, inclusion: { in: [ true, false ] }

  before_validation :ensure_public_id
  before_validation :normalize_email_and_phone
  validate :email_uniqueness_per_campaign, unless: -> { campaign&.allow_duplicate_leads }
  validate :phone_uniqueness_per_campaign, unless: -> { campaign&.allow_duplicate_leads }

  private

  def ensure_public_id
    self.public_id ||= SecureRandom.uuid
  end

  def normalize_email_and_phone
    if self.email_ciphertext.present?
      self.email_ciphertext = self.email_ciphertext.strip.downcase
    end
    if self.phone_ciphertext.present?
      parsed = Phonelib.parse(self.phone_ciphertext)
      if parsed.valid?
        self.phone_ciphertext = parsed.e164
      else
        errors.add(:phone_ciphertext, "is not a valid phone number")
      end
    end
  end

  def email_uniqueness_per_campaign
    return if email_ciphertext.blank? || campaign_id.blank?
    if Lead.where(campaign_id: campaign_id, email_ciphertext: email_ciphertext).where.not(id: id).exists?
      errors.add(:email_ciphertext, "A lead with this email already exists for this campaign.")
    end
  end

  def phone_uniqueness_per_campaign
    return if phone_ciphertext.blank? || campaign_id.blank?
    if Lead.where(campaign_id: campaign_id, phone_ciphertext: phone_ciphertext).where.not(id: id).exists?
      errors.add(:phone_ciphertext, "A lead with this phone number already exists for this campaign.")
    end
  end
end
