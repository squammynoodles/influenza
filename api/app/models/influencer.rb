class Influencer < ApplicationRecord
  has_many :youtube_channels, dependent: :destroy
  has_many :twitter_accounts, dependent: :destroy
  has_many :contents, dependent: :destroy
  has_many :calls, dependent: :destroy

  validates :name, presence: true
end
