# frozen_string_literal: true

module Calls
  class ExtractionService
    SAVE_THRESHOLD = 0.7

    def initialize
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    end

    def extract(content)
      return if content.extraction_status == "completed"

      if content.is_a?(YoutubeVideo) && content.transcript.blank?
        content.update!(extraction_status: "no_transcript")
        return
      end

      if content.is_a?(Tweet) && content.body.blank?
        content.update!(extraction_status: "no_content")
        return
      end

      response = call_openai(content)
      json_string = response.dig("choices", 0, "message", "content")
      all_calls = CallParser.parse(json_string, content)

      saveable_calls = all_calls.select { |c| c.confidence >= SAVE_THRESHOLD }

      ActiveRecord::Base.transaction do
        saveable_calls.each(&:save!)

        status = determine_status(all_calls, saveable_calls)
        content.update!(
          calls_extracted_at: Time.current,
          extraction_status: status
        )
      end

      log_usage(content, response)
    rescue Faraday::Error, Net::OpenTimeout, Net::ReadTimeout => e
      content.update!(extraction_status: "failed")
      Rails.logger.error("ExtractionService: API error for Content ##{content.id}: #{e.message}")
      raise
    end

    private

    def call_openai(content)
      @client.chat(
        parameters: {
          model: "gpt-4o-mini",
          response_format: { type: "json_object" },
          temperature: 0.1,
          max_tokens: 1000,
          messages: [
            { role: "system", content: PromptBuilder.system_prompt },
            { role: "user", content: PromptBuilder.user_prompt(content) }
          ]
        }
      )
    end

    def determine_status(all_calls, saveable_calls)
      if saveable_calls.any?
        "completed"
      elsif all_calls.any?
        "low_confidence"
      else
        "no_calls"
      end
    end

    def log_usage(content, response)
      total_tokens = response.dig("usage", "total_tokens")
      Rails.logger.info(
        "ExtractionService: Processed Content ##{content.id} " \
        "(#{content.type}) - #{total_tokens} tokens used"
      )
    end
  end
end
