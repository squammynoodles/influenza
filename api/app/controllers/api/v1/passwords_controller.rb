module Api
  module V1
    class PasswordsController < ApplicationController
      skip_before_action :require_authentication

      def create
        user = User.find_by(email_address: params[:email])

        if user
          token = user.generate_token_for(:password_reset)
          PasswordsMailer.reset(user, token).deliver_later
        end

        # Always return success to prevent email enumeration
        render json: { message: "If an account exists with that email, you will receive password reset instructions." }, status: :ok
      end

      def update
        user = User.find_by_token_for(:password_reset, params[:token])

        if user.nil?
          render json: { error: "Invalid or expired reset token" }, status: :unprocessable_entity
          return
        end

        if user.update(password: params[:password])
          # Invalidate all existing sessions on password change
          user.sessions.destroy_all

          render json: { message: "Password has been reset successfully." }, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end
