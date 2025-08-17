class Lead < ApplicationRecord
  belongs_to :campaign
  belongs_to :landing_page

  validates :public_id, presence: true
  validates :name, presence: true
  validates :email_ciphertext, presence: true
  validates :phone_ciphertext, presence: true
  validates :marketing_consent, inclusion: { in: [true, false] }

  before_validation :ensure_public_id

  private

  def ensure_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
