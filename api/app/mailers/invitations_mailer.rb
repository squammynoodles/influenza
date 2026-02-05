class InvitationsMailer < ApplicationMailer
  def invite(invitation, token)
    @invitation = invitation
    @token = token
    @signup_url = "#{frontend_url}/signup?token=#{token}"

    mail(
      to: invitation.email,
      subject: "You've been invited to Influenza"
    )
  end

  private

  def frontend_url
    ENV.fetch("FRONTEND_URL", "http://localhost:3001")
  end
end
