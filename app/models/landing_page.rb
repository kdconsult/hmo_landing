class LandingPage < ApplicationRecord
  belongs_to :campaign

  STATUSES = %w[draft published].freeze

  validates :campaign_id, presence: true, uniqueness: true
  # Optional copy fields like headline/subheadline are stored separately; no name field in schema
  validates :slug, presence: true, uniqueness: true
  validates :template, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :schema_version, numericality: { only_integer: true }, allow_nil: true

  scope :published, -> { where(status: "published") }
end
