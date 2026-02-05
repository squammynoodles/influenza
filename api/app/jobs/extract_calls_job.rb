# frozen_string_literal: true

class ExtractCallsJob < ApplicationJob
  queue_as :extraction

  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(content_id)
    content = Content.find(content_id)
    Calls::ExtractionService.new.extract(content)
    Rails.logger.info("Extracted calls for Content ##{content_id}")
  end
end
