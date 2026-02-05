# frozen_string_literal: true

require "httparty"

module Twitter
  class TweetFetcher
    BASE_URL = "https://api.twitterapi.io/twitter"

    class ApiError < StandardError; end
    class RateLimitError < ApiError; end

    def initialize
      @api_key = api_key
    end

    def recent_tweets(username, since: 1.day.ago)
      response = HTTParty.get(
        "#{BASE_URL}/user/last_tweets",
        headers: { "X-API-Key" => @api_key },
        query: { userName: username },
        timeout: 15
      )

      handle_response(response, username, since)
    rescue HTTParty::Error, Timeout::Error => e
      raise ApiError, "Network error fetching tweets for @#{username}: #{e.message}"
    end

    private

    def api_key
      ENV["TWITTER_API_KEY"] || Rails.application.credentials.twitter_api_key ||
        raise(ApiError, "TWITTER_API_KEY not configured")
    end

    def handle_response(response, username, since)
      case response.code
      when 200
        parse_tweets(response.body, since: since)
      when 429
        raise RateLimitError, "Rate limit exceeded for TwitterAPI.io"
      when 401, 403
        raise ApiError, "Authentication failed - check TWITTER_API_KEY"
      when 404
        Rails.logger.warn("Twitter user not found: @#{username}")
        []
      else
        raise ApiError, "TwitterAPI.io error (#{response.code}): #{response.body}"
      end
    end

    def parse_tweets(body, since:)
      data = JSON.parse(body)
      tweets = data["tweets"] || []

      tweets.filter_map do |tweet|
        published_at = parse_time(tweet["createdAt"] || tweet["created_at"])
        next if published_at && published_at < since

        {
          tweet_id: tweet["id"],
          text: tweet["text"],
          published_at: published_at,
          metadata: {
            retweet_count: tweet["retweetCount"] || tweet["retweet_count"],
            like_count: tweet["likeCount"] || tweet["like_count"],
            reply_count: tweet["replyCount"] || tweet["reply_count"],
            is_retweet: tweet["isRetweet"] || tweet["text"]&.start_with?("RT @"),
            is_reply: (tweet["inReplyToId"] || tweet["in_reply_to_id"]).present?
          }
        }
      end
    rescue JSON::ParserError => e
      raise ApiError, "Failed to parse TwitterAPI.io response: #{e.message}"
    end

    def parse_time(time_str)
      return nil unless time_str
      Time.parse(time_str)
    rescue ArgumentError
      nil
    end
  end
end
