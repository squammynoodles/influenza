class Call < ApplicationRecord
  belongs_to :content
  belongs_to :influencer
  belongs_to :asset

  validates :direction, presence: true, inclusion: { in: %w[bullish bearish] }
  validates :confidence, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :called_at, presence: true

  scope :bullish, -> { where(direction: "bullish") }
  scope :bearish, -> { where(direction: "bearish") }
  scope :high_confidence, -> { where("confidence >= ?", 0.7) }
  scope :recent, -> { order(called_at: :desc) }
end
