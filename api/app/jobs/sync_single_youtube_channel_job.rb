# frozen_string_literal: true

class SyncSingleYoutubeChannelJob < ApplicationJob
  queue_as :ingestion
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(channel_id)
    channel = YoutubeChannel.find_by(id: channel_id)
    return unless channel

    Youtube::ChannelSyncService.new(channel).call
  rescue => e
    Rails.logger.error("YouTube sync failed for channel #{channel_id}: #{e.message}")
    raise  # Re-raise for retry
  end
end
