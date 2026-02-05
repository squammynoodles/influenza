module Api
  module V1
    class InvitationsController < ApplicationController
      before_action :require_admin, except: [:verify]
      skip_before_action :require_authentication, only: [:verify]

      def create
        invitation = Invitation.new(
          email: params[:email],
          invited_by: Current.user
        )

        if invitation.save
          token = invitation.generate_token_for(:invitation)
          InvitationsMailer.invite(invitation, token).deliver_later

          render json: {
            token: token,
            email: invitation.email
          }, status: :created
        else
          render json: { errors: invitation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def verify
        invitation = Invitation.find_by_token_for(:invitation, params[:token])

        if invitation.nil?
          render json: { error: "Invalid or expired invitation token" }, status: :unprocessable_entity
          return
        end

        if invitation.accepted?
          render json: { error: "Invitation has already been used" }, status: :unprocessable_entity
          return
        end

        render json: { email: invitation.email }, status: :ok
      end

      private

      def require_admin
        unless Current.user&.admin?
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
