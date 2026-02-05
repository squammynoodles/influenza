class YoutubeChannel < ApplicationRecord
  belongs_to :influencer

  validates :channel_id, presence: true, uniqueness: true
end
