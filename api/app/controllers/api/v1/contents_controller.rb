module Api
  module V1
    class ContentsController < ApplicationController
      before_action :set_influencer

      def index
        contents = @influencer.contents.order(published_at: :desc)
        contents = contents.where(type: classify_type(params[:type])) if params[:type].present?

        page = (params[:page] || 1).to_i
        page = 1 if page < 1

        per_page = params[:per_page].present? ? [[params[:per_page].to_i, 100].min, 1].max : 20

        total = contents.count
        contents = contents.offset((page - 1) * per_page).limit(per_page)

        render json: {
          contents: contents.map { |content| content_json(content) },
          meta: { total: total, page: page, per_page: per_page }
        }
      end

      private

      def set_influencer
        @influencer = Influencer.find(params[:influencer_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Influencer not found" }, status: :not_found
      end

      def classify_type(type)
        case type.to_s.downcase
        when "youtube_video" then "YoutubeVideo"
        when "tweet" then "Tweet"
        else type.classify
        end
      end

      def content_json(content)
        json = {
          id: content.id,
          type: content.type,
          external_id: content.external_id,
          title: content.title,
          body: content.body,
          published_at: content.published_at,
          metadata: content.metadata,
          created_at: content.created_at,
          updated_at: content.updated_at
        }

        # Include transcript for videos
        json[:transcript] = content.transcript if content.is_a?(YoutubeVideo)

        # Include thumbnail_url for videos
        json[:thumbnail_url] = content.thumbnail_url if content.respond_to?(:thumbnail_url)

        json
      end
    end
  end
end
