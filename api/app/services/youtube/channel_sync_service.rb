# frozen_string_literal: true

module Youtube
  class ChannelSyncService
    def initialize(youtube_channel)
      @channel = youtube_channel
      @video_service = VideoListService.new
      @transcript_fetcher = TranscriptFetcher.new
    end

    def call
      return unless @channel.uploads_playlist_id.present?

      videos = @video_service.recent_videos(
        @channel.uploads_playlist_id,
        published_after: last_sync_time
      )

      videos.each do |video_data|
        sync_video(video_data)
      end

      @channel.touch(:last_synced_at)

      Rails.logger.info("YouTube sync completed for #{@channel.title}: #{videos.count} videos processed")
    end

    private

    def last_sync_time
      @channel.last_synced_at || 7.days.ago
    end

    def sync_video(data)
      video = YoutubeVideo.find_or_initialize_by(external_id: data[:video_id])

      # Skip if already exists and has transcript
      return if video.persisted? && video.transcript.present?

      video.assign_attributes(
        influencer: @channel.influencer,
        title: data[:title],
        body: data[:description],
        published_at: data[:published_at],
        metadata: { thumbnail_url: data[:thumbnail_url] }
      )

      # Fetch transcript for new videos
      if video.new_record? || video.transcript.blank?
        begin
          video.transcript = @transcript_fetcher.fetch(data[:video_id])
        rescue TranscriptFetcher::TranscriptNotAvailable => e
          Rails.logger.warn("Transcript not available: #{e.message}")
          video.transcript = nil  # Store without transcript
        end
      end

      video.save!
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to save video #{data[:video_id]}: #{e.message}")
    end
  end
end
