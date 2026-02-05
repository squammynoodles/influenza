# Phase 3: Call Extraction & Price Data - Research

**Researched:** 2026-02-06
**Domain:** LLM-based financial call extraction, modular price data integration
**Confidence:** MEDIUM-HIGH

## Summary

Phase 3 covers two distinct but related subsystems: (1) extracting market calls from existing content (YouTube transcripts and tweets) using an LLM, and (2) fetching historical price data for called assets via modular adapters. The content already exists in the database from Phase 2 -- transcripts in `contents.transcript` and tweet text in `contents.body`. The job is to analyze that text, identify actionable market calls (bullish/bearish on specific assets), and store them as structured `Call` records. Separately, a price data layer must fetch historical prices for any asset referenced in calls.

The recommended approach uses the `ruby-openai` gem (community, v8.3.0, 36M+ downloads) with GPT-4o-mini for call extraction via JSON mode (`response_format: { type: "json_object" }`). GPT-4o-mini at $0.15/1M input tokens is cost-effective for this use case -- processing a typical YouTube transcript (~5000 tokens) costs fractions of a cent. For price data, use HTTParty (already in the project) to call the CoinGecko Demo API for crypto and Yahoo Finance v8/chart endpoint for macro assets directly, implementing a simple Ruby adapter pattern to make providers swappable.

Key risks center on false positive call extraction (40-60% without validation per prior research), ticker symbol disambiguation, and Yahoo Finance's unofficial/fragile API. Mitigation: use carefully crafted system prompts with few-shot examples, enforce structured JSON output with confidence scores, set a minimum confidence threshold of 0.7, and build the Yahoo adapter to be replaceable if the endpoint breaks.

**Primary recommendation:** Use `ruby-openai` gem with GPT-4o-mini and JSON mode for call extraction; use HTTParty directly against CoinGecko and Yahoo Finance APIs with a Ruby adapter pattern for swappable price providers.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| ruby-openai | 8.3.0 | OpenAI API client for LLM call extraction | 36M+ downloads, battle-tested in Rails, supports JSON mode, well-maintained |
| HTTParty | 0.24.2 | HTTP client for price API requests | Already in project from Phase 2, simple interface for REST APIs |
| Solid Queue | (built-in) | Background job processing for extraction pipeline | Already configured from Phase 2, no Redis dependency |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| faraday | >= 1 | HTTP adapter (dependency of ruby-openai) | Pulled in automatically, no separate install needed |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| ruby-openai (community) | openai (official, v0.45.0) | Official SDK has structured outputs via BaseModel but only 80 downloads for current version, very new (released Feb 5, 2026). Too bleeding-edge for production. Revisit in 3-6 months. |
| ruby-openai | ruby_llm | Multi-provider support (Anthropic, Gemini, etc.) but overkill for single-provider use. Only adds value if we need provider switching. |
| HTTParty (direct API calls) | coingecko_ruby gem | Gem is dormant (last release July 2021), likely incompatible with current API. HTTParty direct calls are more maintainable. |
| HTTParty (direct API calls) | alphavantage_rb gem | Alpha Vantage has severe free tier limits (25 calls/day). Yahoo Finance v8/chart is free with no key required. |
| GPT-4o-mini | GPT-4o | 17x more expensive ($2.50 vs $0.15 per 1M input tokens). Mini is sufficient for sentiment/extraction tasks. |

**Installation:**
```bash
# In api/ directory
bundle add ruby-openai
```

Only `ruby-openai` needs to be added. HTTParty and Solid Queue are already in the project.

## Architecture Patterns

### Recommended Project Structure
```
api/
  app/
    models/
      call.rb                        # Call model (belongs_to content, belongs_to influencer)
      asset.rb                       # Asset model (BTC, ETH, NASDAQ, etc.)
      price_snapshot.rb              # Cached price data points
    services/
      calls/
        extraction_service.rb        # Orchestrates extraction from a content item
        prompt_builder.rb            # Builds LLM prompts for different content types
        call_parser.rb               # Parses LLM JSON response into Call records
      prices/
        base_adapter.rb              # Abstract adapter interface
        coingecko_adapter.rb         # CoinGecko implementation for crypto
        yahoo_finance_adapter.rb     # Yahoo Finance implementation for macro
        price_fetcher.rb             # Selects adapter based on asset type
    jobs/
      extract_calls_job.rb           # Per-content extraction job
      extract_all_pending_calls_job.rb  # Batch dispatcher for unprocessed content
      fetch_price_data_job.rb        # Fetches prices for a given asset
      fetch_all_prices_job.rb        # Batch dispatcher for all tracked assets
```

### Pattern 1: LLM Call Extraction with JSON Mode
**What:** Send content text to GPT-4o-mini with a structured system prompt requesting JSON output, parse the response into Call records.
**When to use:** Processing every content item (tweet or transcript) for market calls.
**Example:**
```ruby
# Source: OpenAI API docs + ruby-openai gem
client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

response = client.chat(
  parameters: {
    model: "gpt-4o-mini",
    response_format: { type: "json_object" },
    messages: [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: content_text }
    ],
    temperature: 0.1  # Low temperature for consistent extraction
  }
)

json_str = response.dig("choices", 0, "message", "content")
calls_data = JSON.parse(json_str)
```

### Pattern 2: Adapter Pattern for Price Providers
**What:** Define a common interface for price data, implement per-provider adapters behind it. A factory/fetcher selects the right adapter based on asset type.
**When to use:** Fetching price data for any asset, allowing provider swaps without code changes.
**Example:**
```ruby
# Source: Ruby adapter pattern (rubypatterns.dev, refactoring.guru)
module Prices
  class BaseAdapter
    def historical(asset_id, vs_currency:, days:)
      raise NotImplementedError, "Subclasses must implement #historical"
    end

    def current_price(asset_id, vs_currency:)
      raise NotImplementedError, "Subclasses must implement #current_price"
    end
  end
end

module Prices
  class CoinGeckoAdapter < BaseAdapter
    BASE_URL = "https://api.coingecko.com/api/v3"

    def historical(coin_id, vs_currency: "usd", days: 365)
      response = HTTParty.get(
        "#{BASE_URL}/coins/#{coin_id}/market_chart",
        query: { vs_currency: vs_currency, days: days },
        headers: { "x-cg-demo-api-key" => ENV["COINGECKO_API_KEY"] }
      )
      normalize_response(response)
    end
  end
end

module Prices
  class PriceFetcher
    ADAPTERS = {
      crypto: CoinGeckoAdapter,
      macro: YahooFinanceAdapter
    }.freeze

    def self.for(asset)
      adapter_class = ADAPTERS[asset.asset_class.to_sym]
      adapter_class.new
    end
  end
end
```

### Pattern 3: Processing State on Content Records
**What:** Track extraction status on content records to avoid reprocessing and enable retry logic.
**When to use:** Every content record needs to know if calls have been extracted.
**Example:**
```ruby
# Add to contents table:
# calls_extracted_at: datetime (null = not yet processed)
# extraction_status: string (pending, completed, failed, no_calls)

# In the batch dispatcher job:
Content.where(calls_extracted_at: nil)
       .where.not(transcript: nil)  # Videos need transcripts
       .or(Content.where(calls_extracted_at: nil, type: "Tweet"))
       .find_each do |content|
  ExtractCallsJob.perform_later(content.id)
end
```

### Anti-Patterns to Avoid
- **Processing all content in a single LLM call:** Each content item should be processed individually. Batching content into one prompt loses context and makes error recovery impossible.
- **Storing raw LLM responses without parsing:** Always parse into structured Call records immediately. Raw JSON in a column is unsearchable and unvalidatable.
- **Hard-coding asset IDs/tickers:** Use an Asset lookup table that maps common names, symbols, and CoinGecko/Yahoo IDs. "Bitcoin" / "BTC" / "bitcoin" all resolve to the same asset.
- **Polling price APIs per-request from the frontend:** Always use cached price data from the database. Frontend requests should hit the Rails API, which returns stored PriceSnapshot records.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| LLM API communication | Custom HTTP client for OpenAI | `ruby-openai` gem | Handles auth, retries, streaming, error parsing, rate limits |
| JSON schema validation of LLM output | Manual hash checking | `response_format: { type: "json_object" }` + JSON.parse with rescue | OpenAI guarantees valid JSON; add schema validation with simple hash key checks |
| Ticker symbol resolution | Regex-based ticker extraction | LLM with asset list in prompt | LLM handles context, negation, disambiguation far better than regex |
| Price data caching | Manual cache expiry logic | Rails `expires_in` cache or DB-based with `updated_at` checks | Rails cache handles TTL, invalidation, and fallback natively |
| Background job scheduling | Custom cron implementation | Solid Queue recurring jobs in `recurring.yml` | Already working in Phase 2, proven pattern |
| HTTP request retries | Manual retry loops | HTTParty with timeout + job-level `retry_on` | ActiveJob retry handles transient failures automatically |

**Key insight:** The LLM replaces an entire NLP pipeline. Instead of building keyword extraction + negation detection + sentiment analysis + intent classification as separate steps, a single well-prompted GPT-4o-mini call does all of this. The prompt IS the pipeline.

## Common Pitfalls

### Pitfall 1: False Positive Call Extraction (40-60% Without Mitigation)
**What goes wrong:** LLM extracts "calls" from reporting, hypothetical, or negated statements. "I'm NOT buying Bitcoin here" becomes a bullish BTC call.
**Why it happens:** Financial language is nuanced. Influencers discuss assets without recommending them, reference past positions, or use conditional language.
**How to avoid:**
- Use a detailed system prompt with explicit negative examples ("If the speaker says 'I am not buying X', this is NOT a call")
- Include few-shot examples in the prompt showing correct extraction AND correct rejection
- Require confidence >= 0.7 to create a Call record (store lower-confidence extractions as `extraction_status: "low_confidence"`)
- Set `temperature: 0.1` for deterministic extraction
- Ask the LLM to include the exact quote snippet so users can verify
**Warning signs:** More than 5 calls per typical YouTube video, calls with hedging language ("might", "could", "interesting")

### Pitfall 2: Ticker Symbol Disambiguation
**What goes wrong:** "AI is the future" gets flagged as a call on C3.ai (ticker: AI). Common words match ticker symbols.
**Why it happens:** Many common English words are valid ticker symbols (GO, AI, A, NOW, META).
**How to avoid:**
- Provide the LLM with an explicit list of supported assets in the system prompt (BTC, ETH, SOL, NASDAQ, S&P 500, etc.)
- Only extract calls for assets in the supported list -- do NOT let the LLM invent new tickers
- Use an Asset model with canonical names and aliases for mapping
**Warning signs:** Calls appearing for assets the influencer has never discussed

### Pitfall 3: YouTube Transcripts May Be Missing or Poor Quality
**What goes wrong:** Some content items have no transcript (auto-captions unavailable), leading to extraction failures.
**Why it happens:** YouTube auto-captions are ~62% accurate and not available for all videos. Financial jargon gets mangled.
**How to avoid:**
- Skip extraction for content with no transcript (mark as `extraction_status: "no_transcript"`)
- For tweets, use the `body` field directly (tweets are already text)
- Include a financial terminology note in the LLM prompt: "Common crypto terms include BTC (Bitcoin), ETH (Ethereum), SOL (Solana)..."
**Warning signs:** High percentage of `no_transcript` statuses

### Pitfall 4: CoinGecko Rate Limiting (30 calls/min, 10K/month on Demo)
**What goes wrong:** Price fetching jobs exhaust the monthly quota or hit per-minute limits, causing incomplete price data.
**Why it happens:** 10,000 calls/month = ~333 calls/day. If fetching daily for 20 assets, that's only ~16 days of data per asset per month.
**How to avoid:**
- Fetch price data in bulk (one call per asset covers the full history via the `days` parameter)
- Cache aggressively: historical data does not change, only fetch new data points
- Store price data in PriceSnapshot records, only fetch incremental updates
- Use `days=max` on first fetch, then `days=1` for daily updates
**Warning signs:** 429 responses from CoinGecko, gaps in price data

### Pitfall 5: Yahoo Finance Endpoint Fragility
**What goes wrong:** Yahoo Finance v8/chart endpoint stops working or changes behavior without notice, breaking macro price data.
**Why it happens:** This is an unofficial API. Yahoo has been tightening access with cookie/crumb authentication and rate limiting.
**How to avoid:**
- Build the Yahoo adapter to fail gracefully with clear error logging
- Implement the adapter pattern so Yahoo can be swapped for Alpha Vantage or another provider
- Cache response data aggressively (macro index data changes once per day)
- Add User-Agent header to HTTParty requests to avoid bot detection
- Monitor for 401/403/429 responses and alert
**Warning signs:** Increasing 429 errors, empty responses, "Invalid Crumb" errors

### Pitfall 6: LLM API Costs Accumulating Without Monitoring
**What goes wrong:** Processing 100+ pieces of content per day at GPT-4o-mini prices seems cheap but adds up, especially if retries or long transcripts are involved.
**Why it happens:** A 30-minute YouTube transcript can be 8000+ tokens. At $0.15/1M input tokens, this is still cheap (~$0.001 per call), but monitoring is needed.
**How to avoid:**
- Truncate transcripts to a max length (e.g., 12,000 tokens / ~48,000 chars) to control costs
- Log token usage from API responses (`response["usage"]["total_tokens"]`)
- Set a monthly budget alert
- For very long transcripts, split into chunks and extract from each chunk separately
**Warning signs:** Token usage spiking, cost exceeding $5/month for 5-10 influencers

## Code Examples

Verified patterns from official sources:

### LLM System Prompt for Call Extraction
```ruby
# Carefully engineered prompt for financial call extraction
CALL_EXTRACTION_SYSTEM_PROMPT = <<~PROMPT
  You are a financial content analyst. Your job is to extract market calls
  (trading recommendations) from influencer content.

  A "call" is when the speaker explicitly recommends buying, selling, or
  taking a position on a specific asset. Calls must be:
  - EXPLICIT: The speaker must clearly state a directional opinion
  - ACTIONABLE: Must reference a specific asset (not general market commentary)
  - CURRENT: Must be about a current or future position (not past trades)

  NOT a call:
  - "Bitcoin is interesting" (no direction)
  - "I sold my BTC last week" (past action, not recommendation)
  - "People are buying ETH" (reporting, not recommending)
  - "I would NOT buy NASDAQ here" (this is BEARISH, not bullish)
  - "If Bitcoin hits 100K, then maybe" (hypothetical, too conditional)

  Supported assets: BTC, ETH, SOL, XRP, ADA, DOT, AVAX, LINK, MATIC,
  DOGE, SHIB, NASDAQ, SP500, DXY, GOLD

  Respond with JSON in this exact format:
  {
    "calls": [
      {
        "asset": "BTC",
        "direction": "bullish",
        "confidence": 0.85,
        "quote": "exact quote from the content",
        "reasoning": "brief explanation of why this is a call"
      }
    ]
  }

  If there are NO calls in the content, respond with:
  { "calls": [] }

  Rules:
  - confidence is 0.0 to 1.0 (how certain you are this is a real call)
  - direction is "bullish" or "bearish"
  - asset MUST be from the supported list above
  - quote should be the exact words, max 200 characters
  - Only include calls with confidence >= 0.5
PROMPT
```

### OpenAI Chat Completion with JSON Mode (ruby-openai gem)
```ruby
# Source: ruby-openai gem README + OpenAI API docs
require "openai"

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

response = client.chat(
  parameters: {
    model: "gpt-4o-mini",
    response_format: { type: "json_object" },
    temperature: 0.1,
    max_tokens: 1000,
    messages: [
      { role: "system", content: CALL_EXTRACTION_SYSTEM_PROMPT },
      { role: "user", content: "Analyze this content for market calls:\n\n#{content_text}" }
    ]
  }
)

raw_json = response.dig("choices", 0, "message", "content")
parsed = JSON.parse(raw_json)
calls = parsed["calls"] || []
token_usage = response["usage"]["total_tokens"]
```

### CoinGecko Historical Price Fetch
```ruby
# Source: CoinGecko API docs (docs.coingecko.com)
# Demo API base URL: https://api.coingecko.com/api/v3
# Auth header: x-cg-demo-api-key

response = HTTParty.get(
  "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart",
  query: { vs_currency: "usd", days: 365 },
  headers: {
    "x-cg-demo-api-key" => ENV["COINGECKO_API_KEY"],
    "Accept" => "application/json"
  },
  timeout: 15
)

# Response format:
# {
#   "prices": [[1706745600000, 42150.23], [1706832000000, 42890.11], ...],
#   "market_caps": [[timestamp, value], ...],
#   "total_volumes": [[timestamp, value], ...]
# }

data = response.parsed_response
prices = data["prices"].map do |timestamp_ms, price|
  { timestamp: Time.at(timestamp_ms / 1000).utc, price: price }
end
```

### Yahoo Finance Historical Price Fetch
```ruby
# Source: Yahoo Finance v8/chart API (unofficial but widely used)
# No API key required. Ticker format: ^IXIC (NASDAQ), ^GSPC (S&P 500)

ticker = "^IXIC"  # NASDAQ Composite
period1 = 1.year.ago.to_i   # Unix timestamp
period2 = Time.now.to_i

response = HTTParty.get(
  "https://query1.finance.yahoo.com/v8/finance/chart/#{CGI.escape(ticker)}",
  query: {
    period1: period1,
    period2: period2,
    interval: "1d",
    includeAdjustedClose: true
  },
  headers: {
    "User-Agent" => "Mozilla/5.0 (compatible; Influenza/1.0)"
  },
  timeout: 15
)

# Response structure:
# data["chart"]["result"][0]["timestamp"]  -> array of unix timestamps
# data["chart"]["result"][0]["indicators"]["quote"][0]["close"]  -> array of close prices
# data["chart"]["result"][0]["indicators"]["quote"][0]["open"]
# data["chart"]["result"][0]["indicators"]["quote"][0]["high"]
# data["chart"]["result"][0]["indicators"]["quote"][0]["low"]
# data["chart"]["result"][0]["indicators"]["quote"][0]["volume"]

result = response.parsed_response
chart = result.dig("chart", "result", 0)
timestamps = chart["timestamp"]
quotes = chart.dig("indicators", "quote", 0)

prices = timestamps.each_with_index.map do |ts, i|
  {
    timestamp: Time.at(ts).utc,
    open: quotes["open"][i],
    high: quotes["high"][i],
    low: quotes["low"][i],
    close: quotes["close"][i],
    volume: quotes["volume"][i]
  }
end
```

### Call Model Schema
```ruby
# Migration for calls table
create_table :calls do |t|
  t.references :content, null: false, foreign_key: true
  t.references :influencer, null: false, foreign_key: true
  t.references :asset, null: false, foreign_key: true
  t.string :direction, null: false       # "bullish" or "bearish"
  t.decimal :confidence, null: false     # 0.0 to 1.0
  t.text :quote                          # Exact snippet from content
  t.text :reasoning                      # LLM's reasoning
  t.datetime :called_at, null: false     # When the call was made (content published_at)

  t.timestamps
end

add_index :calls, [:influencer_id, :called_at]
add_index :calls, [:asset_id, :called_at]
add_index :calls, :direction
```

### Asset Model Schema
```ruby
# Migration for assets table
create_table :assets do |t|
  t.string :symbol, null: false           # "BTC", "ETH", "NASDAQ"
  t.string :name, null: false             # "Bitcoin", "Ethereum", "NASDAQ Composite"
  t.string :asset_class, null: false      # "crypto" or "macro"
  t.string :coingecko_id                  # "bitcoin", "ethereum" (for crypto)
  t.string :yahoo_ticker                  # "^IXIC", "^GSPC" (for macro)
  t.jsonb :aliases, default: []           # ["btc", "bitcoin", "BTC/USD"]

  t.timestamps
end

add_index :assets, :symbol, unique: true
add_index :assets, :asset_class
```

### PriceSnapshot Model Schema
```ruby
# Migration for price_snapshots table
create_table :price_snapshots do |t|
  t.references :asset, null: false, foreign_key: true
  t.datetime :timestamp, null: false
  t.decimal :open, precision: 20, scale: 8
  t.decimal :high, precision: 20, scale: 8
  t.decimal :low, precision: 20, scale: 8
  t.decimal :close, precision: 20, scale: 8, null: false
  t.bigint :volume

  t.timestamps
end

add_index :price_snapshots, [:asset_id, :timestamp], unique: true
add_index :price_snapshots, :timestamp
```

### Content Extraction Status Tracking
```ruby
# Migration to add extraction tracking to contents
add_column :contents, :calls_extracted_at, :datetime
add_column :contents, :extraction_status, :string, default: "pending"
# Values: pending, completed, failed, no_calls, no_transcript, low_confidence

add_index :contents, :extraction_status
add_index :contents, :calls_extracted_at
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Regex + keyword matching for call extraction | LLM-based extraction with structured output | 2023-2024 | 10x better accuracy with negation, context, and disambiguation |
| Custom NLP pipeline (tokenize + POS tag + NER + sentiment) | Single LLM prompt replaces entire pipeline | 2023-2024 | Massive reduction in code complexity and maintenance |
| Yahoo Finance official API | Unofficial v8/chart endpoint | 2017 (API shutdown) | No official API; all access is through reverse-engineered endpoints |
| CoinGecko public API (no key) | CoinGecko Demo plan (free key required) | 2024 | Must register for a free API key; provides stable 30 req/min rate limit |
| ruby-openai as only Ruby OpenAI client | Official `openai` gem (v0.45.0) now exists | Feb 2026 | Official SDK has structured outputs via BaseModel, but too new for production use |

**Deprecated/outdated:**
- **youtube-dl**: Unmaintained since 2021, replaced by yt-dlp (not needed here since we use innertube for transcripts)
- **CoinGecko public API without key**: Now requires a Demo API key registration for stable rate limits
- **openai gem v0.x**: The official SDK is pre-1.0; expect breaking API changes. Use ruby-openai 8.x for stability.

## Open Questions

Things that couldn't be fully resolved:

1. **Optimal confidence threshold for call creation**
   - What we know: Prior research suggests 0.7 as a reasonable threshold. GPT-4o-mini's self-assessed confidence correlates moderately with actual accuracy.
   - What's unclear: The exact threshold that balances precision vs. recall for this specific domain. Will need tuning with real data.
   - Recommendation: Start at 0.7, store all extractions >= 0.5 (marking 0.5-0.7 as `low_confidence`), and adjust based on user feedback. This preserves data while filtering the UI.

2. **Yahoo Finance endpoint long-term reliability**
   - What we know: The v8/chart endpoint works today without authentication for basic historical data. But Yahoo has been adding cookie/crumb requirements and rate limiting.
   - What's unclear: Whether Yahoo will fully lock down this endpoint in the near future.
   - Recommendation: Build the adapter pattern so Yahoo can be swapped for Alpha Vantage (free, 25 calls/day) or Financial Modeling Prep. Keep the Yahoo adapter simple and monitor for failures.

3. **Transcript chunk size for long YouTube videos**
   - What we know: GPT-4o-mini supports 128K tokens context window. Most transcripts fit in a single call.
   - What's unclear: Whether very long transcripts (2+ hour videos) should be split into chunks or truncated.
   - Recommendation: Set a practical limit of ~50,000 characters per LLM call. For longer transcripts, split into 50K-char overlapping chunks and extract from each. This keeps costs reasonable while maintaining context.

4. **CoinGecko Demo plan monthly quota adequacy**
   - What we know: 10,000 calls/month. Initial bulk fetch for 15 assets = ~15 calls. Daily updates = ~15 calls/day = ~450/month.
   - What's unclear: Whether quota is sufficient once the system scales to more assets or if we need the Analyst tier ($130/month).
   - Recommendation: Demo plan is sufficient for v1 (5-10 influencers, ~15 tracked assets). Monitor usage and upgrade if needed.

## Sources

### Primary (HIGH confidence)
- [ruby-openai gem](https://github.com/alexrudall/ruby-openai) - v8.3.0, 36M+ downloads, MIT license, supports JSON mode
- [OpenAI API docs - Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs) - JSON mode and json_schema response formats
- [CoinGecko API docs](https://docs.coingecko.com/reference/coins-id-market-chart) - market_chart endpoint, Demo plan details
- [OpenAI Pricing](https://openai.com/api/pricing/) - GPT-4o-mini at $0.15/1M input, $0.60/1M output tokens

### Secondary (MEDIUM confidence)
- [Yahoo Finance v8/chart API](https://scrapfly.io/blog/posts/guide-to-yahoo-finance-api) - Unofficial endpoint documentation, verified working via multiple sources
- [CoinGecko Demo plan](https://support.coingecko.com/hc/en-us/articles/21880397454233) - Free key, 30 calls/min, 10K/month, base URL api.coingecko.com
- [Official OpenAI Ruby SDK](https://github.com/openai/openai-ruby) - v0.45.0, structured outputs via BaseModel (too new for production)
- [Ruby adapter pattern](https://rubypatterns.dev/structural/adapter.html) - Standard structural pattern for swappable interfaces
- [Financial sentiment extraction with GPT](https://www.analyticsvidhya.com/blog/2024/11/financial-sentiment-analysis/) - GPT-4o-mini effective for bullish/bearish classification

### Tertiary (LOW confidence)
- Yahoo Finance long-term endpoint stability - based on community reports and yfinance issue tracker; fragile/unofficial
- LLM confidence score calibration - correlation between self-assessed confidence and actual accuracy is domain-dependent; needs empirical tuning

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - ruby-openai is well-established; CoinGecko API is well-documented; HTTParty already in project
- Architecture: HIGH - Adapter pattern is standard Ruby; extraction pipeline follows established Phase 2 job patterns
- Call extraction prompts: MEDIUM - Prompt engineering is domain-specific; will need tuning with real data
- Yahoo Finance adapter: MEDIUM - Endpoint works today but is unofficial and fragile
- Confidence score thresholds: LOW - Needs empirical validation with real content

**Research date:** 2026-02-06
**Valid until:** 2026-03-06 (30 days -- CoinGecko API and Yahoo Finance stability should be re-verified)
