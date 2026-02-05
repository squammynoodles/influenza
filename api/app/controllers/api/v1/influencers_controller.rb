module Api
  module V1
    class InfluencersController < ApplicationController
      before_action :require_admin, except: [:index, :show]
      before_action :set_influencer, only: [:show, :update, :destroy]

      def index
        influencers = Influencer.all.order(:name)
        render json: { influencers: influencers.map { |inf| influencer_json(inf) } }
      end

      def show
        render json: { influencer: influencer_json(@influencer, include_associations: true) }
      end

      def create
        influencer = Influencer.new(influencer_params)

        if influencer.save
          render json: { influencer: influencer_json(influencer) }, status: :created
        else
          render json: { errors: influencer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @influencer.update(influencer_params)
          render json: { influencer: influencer_json(@influencer) }
        else
          render json: { errors: @influencer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @influencer.destroy
        head :no_content
      end

      private

      def set_influencer
        @influencer = Influencer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Influencer not found" }, status: :not_found
      end

      def influencer_params
        params.require(:influencer).permit(:name, :avatar_url, :bio)
      end

      def influencer_json(influencer, include_associations: false)
        json = {
          id: influencer.id,
          name: influencer.name,
          avatar_url: influencer.avatar_url,
          bio: influencer.bio,
          created_at: influencer.created_at,
          updated_at: influencer.updated_at
        }

        if include_associations
          json[:youtube_channels] = influencer.youtube_channels.map do |channel|
            {
              id: channel.id,
              channel_id: channel.channel_id,
              title: channel.title,
              description: channel.description,
              thumbnail_url: channel.thumbnail_url,
              uploads_playlist_id: channel.uploads_playlist_id,
              last_synced_at: channel.last_synced_at
            }
          end

          json[:twitter_accounts] = influencer.twitter_accounts.map do |account|
            {
              id: account.id,
              username: account.username,
              display_name: account.display_name,
              profile_image_url: account.profile_image_url,
              bio: account.bio,
              last_synced_at: account.last_synced_at
            }
          end
        end

        json
      end

      def require_admin
        unless Current.user&.admin?
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
