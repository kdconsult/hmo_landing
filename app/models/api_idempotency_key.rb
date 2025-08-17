class ApiIdempotencyKey < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :endpoint, presence: true
  validates :request_hash, presence: true

  scope :valid, -> { where("expires_at > ?", Time.current) }
end
