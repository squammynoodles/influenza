# frozen_string_literal: true

module Prices
  class PriceFetcher
    ADAPTERS = {
      "crypto" => Prices::CoingeckoAdapter,
      "macro" => Prices::YahooFinanceAdapter
    }.freeze

    def self.fetch(asset, days: 365)
      adapter = adapter_for(asset)
      adapter.historical(asset, days: days)
    end

    def self.adapter_for(asset)
      adapter_class = ADAPTERS[asset.asset_class]
      raise ArgumentError, "Unknown asset_class: #{asset.asset_class}" unless adapter_class

      adapter_class.new
    end
  end
end
