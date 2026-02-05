class PriceSnapshot < ApplicationRecord
  belongs_to :asset

  validates :timestamp, presence: true, uniqueness: { scope: :asset_id }
  validates :close, presence: true

  scope :chronological, -> { order(timestamp: :asc) }
  scope :for_range, ->(start_time, end_time) { where(timestamp: start_time..end_time) }
end
