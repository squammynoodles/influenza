# frozen_string_literal: true

module Calls
  class CallParser
    VALID_DIRECTIONS = %w[bullish bearish].freeze
    MIN_CONFIDENCE = 0.5

    class << self
      def parse(json_string, content)
        data = JSON.parse(json_string)
        calls_data = data["calls"] || []

        calls_data.filter_map do |call_data|
          build_call(call_data, content)
        end
      rescue JSON::ParserError => e
        Rails.logger.error("CallParser: Failed to parse JSON response: #{e.message}")
        []
      end

      private

      def build_call(call_data, content)
        asset = Asset.find_by(symbol: call_data["asset"])
        return nil unless asset

        direction = call_data["direction"].to_s.downcase
        return nil unless VALID_DIRECTIONS.include?(direction)

        confidence = call_data["confidence"].to_f
        return nil if confidence < MIN_CONFIDENCE

        Call.new(
          content: content,
          influencer: content.influencer,
          asset: asset,
          direction: direction,
          confidence: confidence,
          quote: call_data["quote"].to_s.truncate(200),
          reasoning: call_data["reasoning"],
          called_at: content.published_at || content.created_at
        )
      end
    end
  end
end
