class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :invitations, foreign_key: :invited_by_id, dependent: :nullify

  generates_token_for :password_reset, expires_in: 15.minutes

  validates :email_address,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
