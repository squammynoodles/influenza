class TwitterAccount < ApplicationRecord
  belongs_to :influencer

  validates :username, presence: true, uniqueness: true
end
