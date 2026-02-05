class Asset < ApplicationRecord
  has_many :calls, dependent: :destroy
  has_many :price_snapshots, dependent: :destroy

  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true
  validates :asset_class, presence: true, inclusion: { in: %w[crypto macro] }

  scope :crypto, -> { where(asset_class: "crypto") }
  scope :macro, -> { where(asset_class: "macro") }
end
