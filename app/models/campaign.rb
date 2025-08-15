class Campaign < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :upcoming, -> { where("start_date >= ?", Date.today) }
  scope :past, -> { where("end_date < ?", Date.today) }

  before_create :set_slug

  def self.current
    active.where("start_date <= ? AND end_date >= ?", Date.today, Date.today).order(start_date: :asc)
  end

  def self.upcoming
    active.where("start_date > ?", Date.today).order(start_date: :asc)
  end

  def self.past
    active.where("end_date < ?", Date.today).order(end_date: :desc)
  end

  def self.inactive
    active.where(active: false)
  end

  private

  def set_slug
    self.slug = title.parameterize if slug.blank?
  end
end
