module Api
  module V1
    class PriceSnapshotsController < ApplicationController
      before_action :set_asset

      def index
        start_time = params[:start_date].present? ? Date.parse(params[:start_date]).beginning_of_day : 1.year.ago.beginning_of_day
        end_time = params[:end_date].present? ? Date.parse(params[:end_date]).end_of_day : Time.current

        snapshots = @asset.price_snapshots.for_range(start_time, end_time).chronological

        render json: {
          asset: {
            id: @asset.id,
            symbol: @asset.symbol,
            name: @asset.name
          },
          price_data: snapshots.map { |s| snapshot_json(s) },
          meta: {
            count: snapshots.size,
            start_date: start_time.to_date.iso8601,
            end_date: end_time.to_date.iso8601
          }
        }
      rescue Date::Error
        render json: { error: "Invalid date format. Use YYYY-MM-DD." }, status: :bad_request
      end

      private

      def set_asset
        asset_id = params[:asset_id]

        if asset_id.blank?
          render json: { error: "asset_id is required" }, status: :bad_request
          return
        end

        @asset = Asset.find(asset_id)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Asset not found" }, status: :not_found
      end

      def snapshot_json(snapshot)
        {
          timestamp: snapshot.timestamp.iso8601,
          open: snapshot.open,
          high: snapshot.high,
          low: snapshot.low,
          close: snapshot.close,
          volume: snapshot.volume
        }
      end
    end
  end
end
