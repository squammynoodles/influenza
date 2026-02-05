# frozen_string_literal: true

require "google/apis/youtube_v3"

module Youtube
  class VideoListService
    def initialize
      @service = Google::Apis::YoutubeV3::YouTubeService.new
      @service.key = api_key
    end

    def recent_videos(playlist_id, published_after: 1.day.ago)
      items = []
      page_token = nil

      loop do
        response = @service.list_playlist_items(
          "snippet,contentDetails",
          playlist_id: playlist_id,
          max_results: 50,
          page_token: page_token
        )

        response.items.each do |item|
          published_at = Time.parse(item.content_details.video_published_at)
          break if published_at < published_after

          items << {
            video_id: item.content_details.video_id,
            title: item.snippet.title,
            description: item.snippet.description,
            published_at: published_at,
            thumbnail_url: item.snippet.thumbnails&.medium&.url
          }
        end

        page_token = response.next_page_token
        break unless page_token
      end

      items
    end

    private

    def api_key
      ENV["YOUTUBE_API_KEY"] || Rails.application.credentials.youtube_api_key
    end
  end
end
