# frozen_string_literal: true

module Prices
  class BaseAdapter
    # Returns an array of hashes:
    # [{ timestamp:, open:, high:, low:, close:, volume: }, ...]
    def historical(asset, days: 365)
      raise NotImplementedError, "#{self.class}#historical must be implemented"
    end

    protected

    # Bulk upserts PriceSnapshot records, preventing duplicates via unique index
    # on [asset_id, timestamp].
    def save_snapshots(asset, price_data)
      records = price_data
        .select { |d| d[:close].present? }
        .map do |d|
          {
            asset_id: asset.id,
            timestamp: d[:timestamp],
            open: d[:open],
            high: d[:high],
            low: d[:low],
            close: d[:close],
            volume: d[:volume],
            created_at: Time.current,
            updated_at: Time.current
          }
        end

      return [] if records.empty?

      PriceSnapshot.upsert_all(records, unique_by: [:asset_id, :timestamp])

      Rails.logger.info("Saved #{records.size} price snapshots for #{asset.symbol}")

      records
    end
  end
end
