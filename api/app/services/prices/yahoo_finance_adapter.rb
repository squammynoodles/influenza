# frozen_string_literal: true

require "cgi"

module Prices
  class YahooFinanceAdapter < BaseAdapter
    BASE_URL = "https://query1.finance.yahoo.com/v8/finance/chart"

    def historical(asset, days: 365)
      return [] if asset.yahoo_ticker.blank?

      period1 = days.days.ago.to_i
      period2 = Time.now.to_i

      response = HTTParty.get(
        "#{BASE_URL}/#{CGI.escape(asset.yahoo_ticker)}",
        query: {
          period1: period1,
          period2: period2,
          interval: "1d",
          includeAdjustedClose: true
        },
        headers: {
          "User-Agent" => "Mozilla/5.0 (compatible; Influenza/1.0)"
        },
        timeout: 15
      )

      if [401, 403, 429].include?(response.code)
        Rails.logger.warn("Yahoo Finance returned #{response.code} for #{asset.symbol}")
        return []
      end

      unless response.success?
        Rails.logger.error("Yahoo Finance API error #{response.code} for #{asset.symbol}: #{response.body&.truncate(200)}")
        return []
      end

      result = response.dig("chart", "result")&.first
      return [] if result.nil?

      timestamps = result["timestamp"] || []
      quotes = result.dig("indicators", "quote")&.first || {}

      price_data = timestamps.each_with_index.filter_map do |ts, i|
        close = quotes["close"]&.at(i)
        next if close.nil?

        {
          timestamp: Time.at(ts).utc,
          open: quotes["open"]&.at(i),
          high: quotes["high"]&.at(i),
          low: quotes["low"]&.at(i),
          close: close,
          volume: quotes["volume"]&.at(i)&.to_i
        }
      end

      save_snapshots(asset, price_data)

      price_data
    rescue HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout, JSON::ParserError => e
      Rails.logger.error("Yahoo Finance request failed for #{asset.symbol}: #{e.message}")
      []
    end
  end
end
