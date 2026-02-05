# frozen_string_literal: true

require "open3"

module Youtube
  class VideoListService
    class FetchError < StandardError; end

    def recent_videos(channel_id, published_after: 1.day.ago)
      cmd = [
        "yt-dlp",
        "--flat-playlist",
        "--dump-json",
        "https://www.youtube.com/channel/#{channel_id}/videos"
      ]

      stdout, stderr, status = Open3.capture3(*cmd)

      unless status.success?
        raise FetchError, "yt-dlp failed for channel #{channel_id}: #{stderr.strip}"
      end

      stdout.each_line.filter_map do |line|
        data = JSON.parse(line)
        published_at = data["timestamp"] ? Time.at(data["timestamp"]).utc : nil
        next if published_at && published_at < published_after

        {
          video_id: data["id"],
          title: data["title"],
          description: data["description"],
          published_at: published_at,
          thumbnail_url: data["thumbnail"]
        }
      end
    end
  end
end
