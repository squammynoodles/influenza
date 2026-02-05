class Content < ApplicationRecord
  belongs_to :influencer
  has_many :calls, dependent: :destroy

  validates :external_id, presence: true, uniqueness: { scope: :type }
  validates :type, presence: true

  scope :recent, -> { order(published_at: :desc) }
  scope :videos, -> { where(type: "YoutubeVideo") }
  scope :tweets, -> { where(type: "Tweet") }
end
