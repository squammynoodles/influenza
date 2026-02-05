# frozen_string_literal: true

class FetchPriceDataJob < ApplicationJob
  queue_as :prices

  retry_on HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout,
           wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(asset_id, days: 365)
    asset = Asset.find(asset_id)
    Prices::PriceFetcher.fetch(asset, days: days)
    Rails.logger.info("Fetched price data for #{asset.symbol} (#{asset.asset_class})")
  end
end
