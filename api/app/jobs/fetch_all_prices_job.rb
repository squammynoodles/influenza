# frozen_string_literal: true

class FetchAllPricesJob < ApplicationJob
  queue_as :prices

  def perform
    assets = Asset.joins(:calls).distinct
    count = 0

    assets.each_with_index do |asset, index|
      days = asset.price_snapshots.exists? ? 7 : 365

      FetchPriceDataJob.set(wait: index * 2.seconds).perform_later(asset.id, days: days)
      count += 1
    end

    Rails.logger.info("Enqueued price fetch for #{count} assets")
  end
end
