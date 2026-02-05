module Authentication
  extend ActiveSupport::Concern

  included do
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :require_authentication
    helper_method :authenticated? if respond_to?(:helper_method)
  end

  private

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    authenticate_with_http_token do |token, _options|
      if session = Session.find_by(token: token)
        Current.session = session
        Current.user = session.user
      end
    end
  end

  def request_authentication
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def authenticated?
    Current.user.present?
  end
end
