module Api
  module V1
    class YoutubeChannelsController < ApplicationController
      before_action :require_admin
      before_action :set_influencer

      def create
        youtube_channel = @influencer.youtube_channels.build(youtube_channel_params)

        if youtube_channel.save
          render json: { youtube_channel: youtube_channel_json(youtube_channel) }, status: :created
        else
          render json: { errors: youtube_channel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        youtube_channel = @influencer.youtube_channels.find(params[:id])
        youtube_channel.destroy
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: "YouTube channel not found" }, status: :not_found
      end

      private

      def set_influencer
        @influencer = Influencer.find(params[:influencer_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Influencer not found" }, status: :not_found
      end

      def youtube_channel_params
        params.require(:youtube_channel).permit(
          :channel_id, :title, :description, :thumbnail_url, :uploads_playlist_id
        )
      end

      def youtube_channel_json(channel)
        {
          id: channel.id,
          influencer_id: channel.influencer_id,
          channel_id: channel.channel_id,
          title: channel.title,
          description: channel.description,
          thumbnail_url: channel.thumbnail_url,
          uploads_playlist_id: channel.uploads_playlist_id,
          last_synced_at: channel.last_synced_at,
          created_at: channel.created_at,
          updated_at: channel.updated_at
        }
      end

      def require_admin
        unless Current.user&.admin?
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
