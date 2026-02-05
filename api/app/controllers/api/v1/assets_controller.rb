module Api
  module V1
    class AssetsController < ApplicationController
      def index
        assets = if params[:with_calls] == "true"
          Asset.joins(:calls).distinct
        else
          Asset.all
        end

        assets = assets.where(asset_class: params[:asset_class]) if params[:asset_class].present?
        assets = assets.order(:symbol)

        render json: {
          assets: assets.map { |asset| asset_json(asset) }
        }
      end

      def show
        asset = Asset.find(params[:id])

        render json: {
          asset: asset_json(asset).merge(
            calls_count: asset.calls.count,
            latest_call_at: asset.calls.maximum(:called_at)
          )
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Asset not found" }, status: :not_found
      end

      private

      def asset_json(asset)
        {
          id: asset.id,
          symbol: asset.symbol,
          name: asset.name,
          asset_class: asset.asset_class,
          coingecko_id: asset.coingecko_id,
          yahoo_ticker: asset.yahoo_ticker
        }
      end
    end
  end
end
