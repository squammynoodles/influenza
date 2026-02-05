class PasswordsMailer < ApplicationMailer
  def reset(user, token)
    @user = user
    @token = token
    @reset_url = "#{frontend_url}/reset-password?token=#{token}"

    mail(
      to: user.email_address,
      subject: "Reset your password"
    )
  end

  private

  def frontend_url
    ENV.fetch("FRONTEND_URL", "http://localhost:3001")
  end
end
