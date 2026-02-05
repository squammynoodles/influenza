module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :require_authentication, only: [:create]

      def create
        invitation = Invitation.find_by_token_for(:invitation, params[:invite_token])

        if invitation.nil?
          render json: { error: "Invalid or expired invitation token" }, status: :unprocessable_entity
          return
        end

        if invitation.accepted?
          render json: { error: "Invitation has already been used" }, status: :unprocessable_entity
          return
        end

        user = User.new(
          email_address: invitation.email,
          password: params[:password]
        )

        if user.save
          invitation.update!(accepted_at: Time.current)

          session = user.sessions.create!(
            user_agent: request.user_agent,
            ip_address: request.remote_ip
          )

          render json: {
            token: session.token,
            user: user_json(user)
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        user = params[:id] == "me" ? Current.user : User.find(params[:id])

        if Current.user == user || Current.user.admin?
          render json: { user: user_json(user) }
        else
          render json: { error: "Forbidden" }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      private

      def user_json(user)
        {
          id: user.id,
          email: user.email_address,
          admin: user.admin
        }
      end
    end
  end
end
