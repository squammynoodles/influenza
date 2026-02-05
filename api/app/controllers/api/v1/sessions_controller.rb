module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :require_authentication, only: [:create]

      def create
        user = User.find_by(email_address: params[:email])

        if user&.authenticate(params[:password])
          session = user.sessions.create!(
            user_agent: request.user_agent,
            ip_address: request.remote_ip
          )

          render json: {
            token: session.token,
            user: user_json(user)
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        Current.session.destroy
        head :no_content
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
