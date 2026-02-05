# frozen_string_literal: true

module Twitter
  class AccountSyncService
    def initialize(twitter_account)
      @account = twitter_account
      @tweet_fetcher = TweetFetcher.new
    end

    def call
      tweets = @tweet_fetcher.recent_tweets(
        @account.username,
        since: last_sync_time
      )

      # Filter out retweets - we want original content only
      original_tweets = tweets.reject { |t| t[:metadata][:is_retweet] }

      original_tweets.each do |tweet_data|
        sync_tweet(tweet_data)
      end

      @account.touch(:last_synced_at)

      Rails.logger.info("Twitter sync completed for @#{@account.username}: #{original_tweets.count} tweets processed")
    rescue TweetFetcher::RateLimitError => e
      Rails.logger.warn("Twitter rate limit hit for @#{@account.username}, will retry later")
      raise # Re-raise for job retry
    end

    private

    def last_sync_time
      @account.last_synced_at || 7.days.ago
    end

    def sync_tweet(data)
      tweet = Tweet.find_or_initialize_by(external_id: data[:tweet_id])

      # Skip if already exists
      return if tweet.persisted?

      tweet.assign_attributes(
        influencer: @account.influencer,
        body: data[:text],
        published_at: data[:published_at],
        metadata: data[:metadata]
      )

      tweet.save!
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to save tweet #{data[:tweet_id]}: #{e.message}")
    end
  end
end
