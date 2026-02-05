class Invitation < ApplicationRecord
  belongs_to :invited_by, class_name: "User", optional: true

  generates_token_for :invitation, expires_in: 7.days do
    accepted_at
  end

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(e) { e.strip.downcase }

  scope :pending, -> { where(accepted_at: nil) }

  def accepted?
    accepted_at.present?
  end
end
