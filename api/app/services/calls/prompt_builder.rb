# frozen_string_literal: true

module Calls
  class PromptBuilder
    SUPPORTED_ASSETS = %w[BTC ETH SOL XRP ADA DOT AVAX LINK MATIC DOGE SHIB NASDAQ SP500 DXY GOLD].freeze

    MAX_CONTENT_LENGTH = 50_000

    SYSTEM_PROMPT = <<~PROMPT
      You are a financial content analyst. Your job is to extract market calls
      (trading recommendations) from influencer content.

      A "call" is when the speaker explicitly recommends buying, selling, or
      taking a position on a specific asset. Calls must be:
      - EXPLICIT: The speaker must clearly state a directional opinion
      - ACTIONABLE: Must reference a specific asset (not general market commentary)
      - CURRENT: Must be about a current or future position (not past trades)

      NOT a call (do NOT extract these):
      - "Bitcoin is interesting" (no direction)
      - "I sold my BTC last week" (past action, not recommendation)
      - "People are buying ETH" (reporting others' actions, not recommending)
      - "I would NOT buy NASDAQ here" (this is BEARISH, not bullish -- only extract if clearly bearish)
      - "If Bitcoin hits 100K, then maybe" (hypothetical, too conditional)
      - "BTC might go up" (hedging language, low confidence)
      - "I'm watching SOL closely" (observation, no direction)

      Supported assets (ONLY extract calls for these):
      #{SUPPORTED_ASSETS.join(", ")}

      Common name mappings:
      - Bitcoin = BTC
      - Ethereum/Ether = ETH
      - Solana = SOL
      - Ripple = XRP
      - Cardano = ADA
      - Polkadot = DOT
      - Avalanche = AVAX
      - Chainlink = LINK
      - Polygon = MATIC
      - Dogecoin = DOGE
      - Shiba Inu = SHIB
      - NASDAQ/Nasdaq Composite = NASDAQ
      - S&P 500/S&P500 = SP500
      - US Dollar Index = DXY
      - Gold/XAUUSD = GOLD

      Respond with JSON in this exact format:
      {
        "calls": [
          {
            "asset": "BTC",
            "direction": "bullish",
            "confidence": 0.85,
            "quote": "exact quote from the content, max 200 characters",
            "reasoning": "brief explanation of why this is a call"
          }
        ]
      }

      If there are NO calls in the content, respond with:
      { "calls": [] }

      Rules:
      - confidence is 0.0 to 1.0 (how certain you are this is a real, actionable call)
      - direction MUST be "bullish" or "bearish"
      - asset MUST be from the supported list above -- do NOT invent new tickers
      - quote should be the exact words from the content, max 200 characters
      - reasoning should be 1-2 sentences explaining why you classified this as a call
      - Only include calls with confidence >= 0.5
      - Be conservative: when in doubt, do NOT extract a call
    PROMPT

    class << self
      def system_prompt
        SYSTEM_PROMPT
      end

      def user_prompt(content)
        text = case content.type
        when "YoutubeVideo"
          "Analyze this YouTube video transcript for market calls:\n\nTitle: #{content.title}\n\n#{content.transcript}"
        when "Tweet"
          "Analyze this tweet for market calls:\n\n#{content.body}"
        else
          "Analyze this content for market calls:\n\n#{content.body}"
        end

        truncate(text, MAX_CONTENT_LENGTH)
      end

      private

      def truncate(text, max_length)
        return text if text.nil? || text.length <= max_length

        text[0...max_length]
      end
    end
  end
end
