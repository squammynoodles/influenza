# frozen_string_literal: true

module Prices
  class CoingeckoAdapter < BaseAdapter
    BASE_URL = "https://api.coingecko.com/api/v3"

    def historical(asset, days: 365)
      return [] if asset.coingecko_id.blank?

      response = HTTParty.get(
        "#{BASE_URL}/coins/#{asset.coingecko_id}/ohlc",
        query: { vs_currency: "usd", days: days },
        headers: {
          "x-cg-demo-api-key" => ENV["COINGECKO_API_KEY"],
          "Accept" => "application/json"
        },
        timeout: 15
      )

      if response.code == 429
        Rails.logger.warn("CoinGecko rate limit hit for #{asset.symbol}, will retry later")
        return []
      end

      unless response.success?
        Rails.logger.error("CoinGecko API error #{response.code} for #{asset.symbol}: #{response.body&.truncate(200)}")
        return []
      end

      # OHLC endpoint returns: [[timestamp_ms, open, high, low, close], ...]
      price_data = response.parsed_response.map do |entry|
        ts_ms, open, high, low, close = entry

        {
          timestamp: Time.at(ts_ms / 1000).utc,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: nil
        }
      end

      save_snapshots(asset, price_data)

      price_data
    rescue HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error("CoinGecko request failed for #{asset.symbol}: #{e.message}")
      []
    end
  end
end
