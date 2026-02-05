# frozen_string_literal: true

class SyncSingleTwitterAccountJob < ApplicationJob
  queue_as :ingestion

  # Retry with exponential backoff, especially for rate limits
  retry_on Twitter::TweetFetcher::RateLimitError,
           wait: :polynomially_longer,
           attempts: 5

  retry_on Twitter::TweetFetcher::ApiError,
           wait: :polynomially_longer,
           attempts: 3

  def perform(account_id)
    account = TwitterAccount.find_by(id: account_id)
    return unless account

    Twitter::AccountSyncService.new(account).call
  rescue => e
    Rails.logger.error("Twitter sync failed for account #{account_id}: #{e.message}")
    raise # Re-raise for retry
  end
end
