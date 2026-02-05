module Api
  module V1
    class CallsController < ApplicationController
      before_action :set_influencer, only: [:index], if: -> { params[:influencer_id].present? }

      def index
        calls = base_scope

        calls = calls.where(influencer_id: @influencer.id) if @influencer
        calls = calls.where(influencer_id: params[:influencer_id]) if params[:influencer_id].present? && @influencer.nil?
        calls = calls.where(asset_id: params[:asset_id]) if params[:asset_id].present?
        calls = calls.where(direction: params[:direction]) if params[:direction].present?

        if params[:min_confidence].present?
          calls = calls.where("confidence >= ?", params[:min_confidence].to_f)
        end

        total = calls.count
        calls = calls.offset((page - 1) * per_page).limit(per_page)

        render json: {
          calls: calls.map { |call| call_json(call) },
          meta: {
            total: total,
            page: page,
            per_page: per_page,
            total_pages: (total.to_f / per_page).ceil
          }
        }
      end

      private

      def base_scope
        Call.includes(:asset, :influencer, :content).high_confidence.recent
      end

      def page
        @page ||= [(params[:page] || 1).to_i, 1].max
      end

      def per_page
        @per_page ||= params[:per_page].present? ? [[params[:per_page].to_i, 100].min, 1].max : 25
      end

      def set_influencer
        @influencer = Influencer.find(params[:influencer_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Influencer not found" }, status: :not_found
      end

      def call_json(call)
        {
          id: call.id,
          direction: call.direction,
          confidence: call.confidence,
          quote: call.quote,
          reasoning: call.reasoning,
          called_at: call.called_at,
          asset: {
            id: call.asset.id,
            symbol: call.asset.symbol,
            name: call.asset.name,
            asset_class: call.asset.asset_class
          },
          influencer: {
            id: call.influencer.id,
            name: call.influencer.name,
            avatar_url: call.influencer.avatar_url
          },
          content: {
            id: call.content.id,
            type: call.content.type,
            title: call.content.title,
            external_id: call.content.external_id
          }
        }
      end
    end
  end
end
