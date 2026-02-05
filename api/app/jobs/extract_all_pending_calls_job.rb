# frozen_string_literal: true

class ExtractAllPendingCallsJob < ApplicationJob
  queue_as :extraction

  def perform
    pending_content = Content.where(extraction_status: [ "pending", nil ])
    count = 0

    pending_content.find_each do |content|
      next if content.is_a?(YoutubeVideo) && content.transcript.blank?
      next if content.is_a?(Tweet) && content.body.blank?

      ExtractCallsJob.perform_later(content.id)
      count += 1
    end

    Rails.logger.info("Enqueued extraction for #{count} content items")
  end
end
