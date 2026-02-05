module Api
  module V1
    class TwitterAccountsController < ApplicationController
      before_action :require_admin
      before_action :set_influencer

      def create
        twitter_account = @influencer.twitter_accounts.build(twitter_account_params)

        if twitter_account.save
          render json: { twitter_account: twitter_account_json(twitter_account) }, status: :created
        else
          render json: { errors: twitter_account.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        twitter_account = @influencer.twitter_accounts.find(params[:id])
        twitter_account.destroy
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Twitter account not found" }, status: :not_found
      end

      private

      def set_influencer
        @influencer = Influencer.find(params[:influencer_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Influencer not found" }, status: :not_found
      end

      def twitter_account_params
        params.require(:twitter_account).permit(
          :username, :display_name, :profile_image_url, :bio
        )
      end

      def twitter_account_json(account)
        {
          id: account.id,
          influencer_id: account.influencer_id,
          username: account.username,
          display_name: account.display_name,
          profile_image_url: account.profile_image_url,
          bio: account.bio,
          last_synced_at: account.last_synced_at,
          created_at: account.created_at,
          updated_at: account.updated_at
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
