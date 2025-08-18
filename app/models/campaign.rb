class Campaign < ApplicationRecord
  has_one :landing_page, dependent: :destroy
  has_many :leads, dependent: :restrict_with_error
  validates :title, presence: true
  validates :body, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  # Allow duplicate leads (email/phone) if true, default false
  attribute :allow_duplicate_leads, :boolean, default: false

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :current, -> {
    where(active: true)
      .where("start_date <= ? AND end_date >= ?", Date.current, Date.current)
      .order(start_date: :asc)
  }
  scope :upcoming, -> {
    where(active: true)
      .where("start_date > ?", Date.current)
      .order(start_date: :asc)
  }
  scope :past, -> {
    where(active: true)
      .where("end_date < ?", Date.current)
      .order(end_date: :desc)
  }

  before_save :set_slug

  private

  def set_slug
    self.slug = title.parameterize if slug.blank?
  end
end
