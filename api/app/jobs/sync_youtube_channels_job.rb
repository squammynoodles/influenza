# frozen_string_literal: true

class SyncYoutubeChannelsJob < ApplicationJob
  queue_as :ingestion

  def perform
    YoutubeChannel.find_each do |channel|
      SyncSingleYoutubeChannelJob.perform_later(channel.id)
    end
  end
end
