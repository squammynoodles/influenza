# Architecture Research

**Domain:** Influencer/Financial Call Tracking Platform
**Researched:** 2026-02-05
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Chart UI   │  │  Influencer  │  │    Call      │          │
│  │  (Next.js)   │  │  Dashboard   │  │   Timeline   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                 │                   │
├─────────┴─────────────────┴─────────────────┴───────────────────┤
│                     API GATEWAY LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Rails API (Backend)                         │   │
│  │  /api/v1/influencers, /calls, /charts                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│         │                 │                 │                   │
├─────────┴─────────────────┴─────────────────┴───────────────────┤
│                   APPLICATION SERVICES                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  Content │  │   Call   │  │  Price   │  │  Chart   │        │
│  │ Ingestion│  │Extraction│  │Aggregator│  │ Builder  │        │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
│       │             │             │             │               │
├───────┴─────────────┴─────────────┴─────────────┴───────────────┤
│                  DATA INTEGRATION LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ YouTube  │  │ Twitter  │  │CoinGecko │  │ Binance  │        │
│  │ Adapter  │  │ Adapter  │  │ Adapter  │  │ Adapter  │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
│       │             │             │             │               │
├───────┴─────────────┴─────────────┴─────────────┴───────────────┤
│               BACKGROUND PROCESSING LAYER                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │   Active Job     │  │   Solid Queue    │                     │
│  │ (Async Workers)  │  │  (Scheduler)     │                     │
│  └──────────────────┘  └──────────────────┘                     │
│         │                      │                                │
├─────────┴──────────────────────┴─────────────────────────────────┤
│                      DATA STORAGE LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  PostgreSQL  │  │   Redis      │  │  S3/Storage  │          │
│  │  (Primary)   │  │  (Cache)     │  │  (Media)     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| **Next.js Frontend** | UI rendering, chart display, user interactions | Next.js App Router, React components, TradingView Charting Library |
| **Rails API** | RESTful endpoints, authentication, business logic orchestration | Rails API-only mode, JWT auth, ActiveRecord |
| **Content Ingestion Service** | Pull videos/tweets, queue processing jobs | Rails service objects, YouTube Data API v3, Twitter API v2 |
| **Call Extraction Service** | Transcribe content, extract calls via NLP/LLM | Whisper API for transcription, GPT-4 for entity extraction |
| **Price Aggregator Service** | Fetch historical/real-time price data | Modular adapter pattern, CoinGecko/Binance APIs |
| **Chart Builder Service** | Combine price data with call markers | OHLCV aggregation, overlay calculation |
| **Adapters (YouTube/Twitter/Price)** | Normalize external API responses | Adapter pattern, standardized interface |
| **Background Jobs** | Scheduled/async processing | ActiveJob + Solid Queue (Rails 8+) or Sidekiq |
| **PostgreSQL** | Structured data (influencers, calls, prices) | Normalized schema with indexes on timestamps |
| **Redis** | Job queue, rate limit tracking, API cache | Optional for caching, required if using Sidekiq |
| **S3/Storage** | Video thumbnails, cached transcriptions | Cloud storage for media assets |

## Recommended Project Structure

### Backend (Rails)

```
app/
├── controllers/
│   └── api/
│       └── v1/
│           ├── influencers_controller.rb    # CRUD for influencers
│           ├── calls_controller.rb          # CRUD for calls
│           ├── charts_controller.rb         # Chart data endpoints
│           └── price_data_controller.rb     # Price history endpoints
├── models/
│   ├── influencer.rb                        # Influencer entity
│   ├── call.rb                              # Extracted call entity
│   ├── price_snapshot.rb                    # Historical price data
│   └── content_source.rb                    # YouTube/Twitter sources
├── services/
│   ├── content_ingestion/
│   │   ├── youtube_ingestor.rb             # Fetch YouTube videos
│   │   ├── twitter_ingestor.rb             # Fetch tweets
│   │   └── base_ingestor.rb                # Shared logic
│   ├── call_extraction/
│   │   ├── transcription_service.rb        # Audio-to-text
│   │   ├── nlp_extractor_service.rb        # Extract calls from text
│   │   └── call_validator_service.rb       # Validate extracted calls
│   ├── price_aggregation/
│   │   ├── price_fetcher_service.rb        # Orchestrate price fetching
│   │   └── ohlcv_builder_service.rb        # Build OHLCV candlesticks
│   └── chart_builder/
│       └── overlay_service.rb               # Combine prices + calls
├── adapters/
│   ├── content/
│   │   ├── youtube_adapter.rb              # YouTube API wrapper
│   │   └── twitter_adapter.rb              # Twitter API wrapper
│   └── price/
│       ├── base_price_adapter.rb           # Adapter interface
│       ├── coingecko_adapter.rb            # CoinGecko implementation
│       ├── binance_adapter.rb              # Binance implementation
│       └── coinmarketcap_adapter.rb        # CoinMarketCap implementation
├── jobs/
│   ├── hourly_youtube_sync_job.rb          # Scheduled batch processing
│   ├── process_video_job.rb                # Async video processing
│   ├── extract_calls_job.rb                # Async call extraction
│   └── fetch_price_data_job.rb             # Price data updates
└── lib/
    └── tradingview/
        └── chart_formatter.rb               # Format data for TradingView

config/
├── initializers/
│   ├── solid_queue.rb                       # Background job config
│   └── adapters.rb                          # Register price adapters
└── recurring.yml                            # Scheduled job definitions
```

### Frontend (Next.js)

```
app/
├── (dashboard)/
│   ├── influencers/
│   │   ├── page.tsx                        # Influencer list
│   │   └── [id]/
│   │       └── page.tsx                    # Influencer detail + chart
│   └── layout.tsx                          # Dashboard layout
├── api/                                     # BFF endpoints (optional)
│   └── charts/
│       └── route.ts                        # Server-side chart data proxy
├── components/
│   ├── charts/
│   │   ├── TradingViewChart.tsx           # TradingView wrapper
│   │   ├── CallOverlay.tsx                # Call marker rendering
│   │   └── ChartControls.tsx              # Timeframe selectors
│   ├── influencers/
│   │   ├── InfluencerCard.tsx
│   │   └── InfluencerGrid.tsx
│   └── ui/                                 # shadcn/ui components
├── lib/
│   ├── api/
│   │   ├── client.ts                       # Rails API client
│   │   ├── influencers.ts                  # Influencer API calls
│   │   ├── calls.ts                        # Calls API calls
│   │   └── charts.ts                       # Chart data API calls
│   └── tradingview/
│       └── chartConfig.ts                  # TradingView chart config
└── types/
    ├── influencer.ts                       # TypeScript types
    ├── call.ts
    └── chart.ts
```

### Structure Rationale

- **Backend Services Pattern**: Services encapsulate business logic, keeping controllers thin and models focused on data
- **Adapter Layer**: External APIs change frequently; adapters isolate integration complexity and enable easy switching
- **Job-Based Processing**: Content ingestion and extraction are expensive; async processing prevents API timeouts
- **BFF Layer (Optional)**: Next.js API routes can aggregate multiple Rails endpoints or add caching, but not required for MVP
- **Type Safety**: Shared TypeScript types ensure frontend/backend contract alignment

## Architectural Patterns

### Pattern 1: Modular Adapter Pattern for Price Sources

**What:** Create a standardized interface for all price data sources, with each provider implemented as a separate adapter. The system can query multiple sources and select/aggregate data without knowing provider-specific details.

**When to use:** When integrating multiple third-party APIs with different interfaces (CoinGecko, Binance, CoinMarketCap)

**Trade-offs:**
- **Pros**: Easy to add new providers, swap implementations, and test in isolation; system remains loosely coupled
- **Cons**: Additional abstraction layer adds slight complexity; may over-engineer if only using one provider

**Example:**
```ruby
# app/adapters/price/base_price_adapter.rb
module Price
  class BasePriceAdapter
    def fetch_current_price(symbol)
      raise NotImplementedError
    end

    def fetch_historical_ohlcv(symbol, from_timestamp, to_timestamp, interval: '1h')
      raise NotImplementedError
    end

    def normalize_response(raw_data)
      raise NotImplementedError
    end
  end
end

# app/adapters/price/coingecko_adapter.rb
module Price
  class CoingeckoAdapter < BasePriceAdapter
    def fetch_current_price(symbol)
      response = HTTParty.get("https://api.coingecko.com/api/v3/simple/price",
        query: { ids: normalize_symbol(symbol), vs_currencies: 'usd' })
      normalize_response(response)
    end

    def fetch_historical_ohlcv(symbol, from_timestamp, to_timestamp, interval: '1h')
      response = HTTParty.get("https://api.coingecko.com/api/v3/coins/#{normalize_symbol(symbol)}/ohlc",
        query: { vs_currency: 'usd', from: from_timestamp, to: to_timestamp })
      normalize_response(response)
    end

    private

    def normalize_symbol(symbol)
      # Convert "BTC" to "bitcoin" for CoinGecko
      SYMBOL_MAP[symbol.upcase] || symbol.downcase
    end

    def normalize_response(raw_data)
      # Transform CoinGecko format to standard internal format
      { price: raw_data.dig('bitcoin', 'usd'), source: 'coingecko', timestamp: Time.current }
    end
  end
end

# app/services/price_aggregation/price_fetcher_service.rb
class PriceAggregation::PriceFetcherService
  def initialize(adapter: :coingecko)
    @adapter = PriceAdapterRegistry.get(adapter)
  end

  def fetch_price_at_time(symbol, timestamp)
    @adapter.fetch_historical_ohlcv(symbol, timestamp - 1.hour, timestamp + 1.hour)
  end
end
```

### Pattern 2: Background Job Pipeline for Content Processing

**What:** Chain multiple asynchronous jobs to process content through stages: ingestion → transcription → extraction → validation. Each stage completes independently and triggers the next, enabling retries and parallel processing.

**When to use:** When processing is expensive (API rate limits, transcription time, LLM calls) and shouldn't block HTTP requests

**Trade-offs:**
- **Pros**: Horizontal scalability, fault tolerance, automatic retries, rate limit management
- **Cons**: Eventual consistency (data not immediately available), requires job queue infrastructure

**Example:**
```ruby
# app/jobs/hourly_youtube_sync_job.rb
class HourlyYoutubeSyncJob < ApplicationJob
  queue_as :scheduled

  def perform
    Influencer.with_youtube_source.find_each do |influencer|
      ProcessYoutubeChannelJob.perform_later(influencer.id)
    end
  end
end

# app/jobs/process_youtube_channel_job.rb
class ProcessYoutubeChannelJob < ApplicationJob
  queue_as :content_ingestion

  def perform(influencer_id)
    influencer = Influencer.find(influencer_id)
    videos = ContentIngestion::YoutubeIngestor.new(influencer).fetch_recent_videos

    videos.each do |video_data|
      ProcessVideoJob.perform_later(influencer_id, video_data)
    end
  end
end

# app/jobs/process_video_job.rb
class ProcessVideoJob < ApplicationJob
  queue_as :transcription

  def perform(influencer_id, video_data)
    # Download audio, transcribe
    transcript = CallExtraction::TranscriptionService.new(video_data[:audio_url]).transcribe

    # Queue call extraction
    ExtractCallsJob.perform_later(influencer_id, video_data[:id], transcript)
  end
end

# app/jobs/extract_calls_job.rb
class ExtractCallsJob < ApplicationJob
  queue_as :nlp_processing

  def perform(influencer_id, video_id, transcript)
    calls = CallExtraction::NlpExtractorService.new(transcript).extract_calls

    calls.each do |call_data|
      Call.create!(
        influencer_id: influencer_id,
        source_type: 'youtube',
        source_id: video_id,
        coin: call_data[:coin],
        direction: call_data[:direction],
        timestamp: call_data[:timestamp]
      )

      # Queue price data fetch for this call
      FetchPriceDataJob.perform_later(call_data[:coin], call_data[:timestamp])
    end
  end
end
```

### Pattern 3: Backend-for-Frontend (BFF) with Next.js API Routes

**What:** Next.js API routes act as an intermediary layer between the frontend and Rails API, aggregating multiple backend calls, adding client-specific transformations, or implementing caching strategies.

**When to use:** When frontend needs data from multiple Rails endpoints, or when you want to reduce client-server roundtrips

**Trade-offs:**
- **Pros**: Reduced network calls, frontend-optimized responses, backend changes isolated from client
- **Cons**: Additional layer to maintain, potential duplication of logic, increased deployment complexity

**Example:**
```typescript
// app/api/charts/[influencerId]/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(
  request: NextRequest,
  { params }: { params: { influencerId: string } }
) {
  try {
    // Fetch influencer, calls, and price data in parallel
    const [influencer, calls, priceData] = await Promise.all([
      fetch(`${process.env.RAILS_API_URL}/api/v1/influencers/${params.influencerId}`),
      fetch(`${process.env.RAILS_API_URL}/api/v1/calls?influencer_id=${params.influencerId}`),
      fetch(`${process.env.RAILS_API_URL}/api/v1/charts/${params.influencerId}/price_data`)
    ])

    // Aggregate responses into chart-ready format
    const chartData = {
      influencer: await influencer.json(),
      calls: await calls.json(),
      ohlcv: await priceData.json()
    }

    // Transform to TradingView format
    const tradingViewData = transformToTradingView(chartData)

    return NextResponse.json(tradingViewData)
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch chart data' }, { status: 500 })
  }
}

function transformToTradingView(data: any) {
  return {
    bars: data.ohlcv.map((bar: any) => ({
      time: bar.timestamp,
      open: bar.open,
      high: bar.high,
      low: bar.low,
      close: bar.close,
      volume: bar.volume
    })),
    markers: data.calls.map((call: any) => ({
      time: call.timestamp,
      position: call.direction === 'long' ? 'belowBar' : 'aboveBar',
      color: call.direction === 'long' ? '#26a69a' : '#ef5350',
      shape: call.direction === 'long' ? 'arrowUp' : 'arrowDown',
      text: `${call.coin} ${call.direction.toUpperCase()}`
    }))
  }
}
```

### Pattern 4: Event-Driven Call Detection Pipeline

**What:** Emit domain events when calls are detected, allowing multiple subscribers (price fetcher, notification service, analytics) to react independently without tight coupling.

**When to use:** When multiple actions need to happen after call extraction (fetch prices, notify users, log analytics)

**Trade-offs:**
- **Pros**: Decoupled components, easy to add new reactions, clear separation of concerns
- **Cons**: More complex than direct method calls, harder to debug event flow

**Example:**
```ruby
# app/events/call_detected_event.rb
class CallDetectedEvent
  attr_reader :call

  def initialize(call)
    @call = call
  end
end

# app/subscribers/price_data_subscriber.rb
class PriceDataSubscriber
  def call_detected(event)
    call = event.call
    FetchPriceDataJob.perform_later(call.coin, call.timestamp)
  end
end

# app/subscribers/analytics_subscriber.rb
class AnalyticsSubscriber
  def call_detected(event)
    call = event.call
    AnalyticsTracker.track('call_detected', {
      influencer_id: call.influencer_id,
      coin: call.coin,
      direction: call.direction
    })
  end
end

# app/services/call_extraction/nlp_extractor_service.rb
class CallExtraction::NlpExtractorService
  def extract_calls(transcript)
    # ... extraction logic ...

    calls.each do |call_data|
      call = Call.create!(call_data)

      # Publish event instead of directly calling other services
      EventBus.publish(CallDetectedEvent.new(call))
    end
  end
end

# config/initializers/event_bus.rb
EventBus.configure do |config|
  config.subscribe('call_detected', PriceDataSubscriber.new)
  config.subscribe('call_detected', AnalyticsSubscriber.new)
end
```

## Data Flow

### Primary Data Flows

#### Flow 1: Content Ingestion → Call Extraction (Batch)

```
┌─────────────────┐
│  Cron Scheduler │ (Every hour)
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│ HourlyYoutubeSyncJob │ (Queues channel processing)
└────────┬─────────────┘
         │
         ▼
┌──────────────────────────┐
│ ProcessYoutubeChannelJob │ (Fetch recent videos via YouTube API)
└────────┬─────────────────┘
         │
         ▼
┌──────────────────┐
│ ProcessVideoJob  │ (Download audio, transcribe via Whisper)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ExtractCallsJob  │ (NLP/LLM extracts calls from transcript)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Create Call    │ (Save to database)
│     Records      │
└────────┬─────────┘
         │
         ▼
┌──────────────────────┐
│ FetchPriceDataJob    │ (Get historical prices at call timestamp)
└──────────────────────┘
```

**Key characteristics:**
- **Asynchronous**: Each stage runs independently
- **Retryable**: Failed jobs automatically retry
- **Rate-limited**: Adapters handle API rate limits
- **Scalable**: Multiple workers can process jobs in parallel

#### Flow 2: Real-Time Twitter Monitoring (Optional Future)

```
┌──────────────────┐
│ Twitter Webhook  │ (Real-time tweet notifications)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ProcessTweetJob  │ (Immediate processing)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ExtractCallsJob  │ (Extract calls from tweet text)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Create Call    │
│     Records      │
└────────┬─────────┘
         │
         ▼
┌──────────────────────┐
│ FetchPriceDataJob    │
└──────────────────────┘
```

**Key characteristics:**
- **Event-driven**: Triggered by Twitter webhooks
- **Low-latency**: Processes tweets within seconds
- **Lightweight**: Text-only processing (no transcription)

#### Flow 3: User Views Chart (Request)

```
┌──────────────┐
│ User clicks  │
│  influencer  │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ Next.js page loads   │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────────┐
│ GET /api/v1/charts/:id   │ (Rails API)
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ ChartBuilderService      │ (Aggregate calls + prices)
└──────┬───────────────────┘
       │
       ├─────────────────────┐
       │                     │
       ▼                     ▼
┌──────────────┐    ┌──────────────────┐
│ Fetch Calls  │    │ Fetch Price Data │
│ from DB      │    │ from DB          │
└──────┬───────┘    └──────┬───────────┘
       │                     │
       └──────────┬──────────┘
                  │
                  ▼
        ┌──────────────────────┐
        │ Format for           │
        │ TradingView          │
        └──────┬───────────────┘
               │
               ▼
        ┌──────────────────────┐
        │ Return JSON          │
        └──────┬───────────────┘
               │
               ▼
        ┌──────────────────────┐
        │ TradingViewChart     │ (Render chart with markers)
        │ component            │
        └──────────────────────┘
```

**Key characteristics:**
- **Synchronous**: User waits for response
- **Read-heavy**: No writes during chart view
- **Cacheable**: Chart data can be cached with short TTL
- **Optimized**: Database indexes on timestamps for fast queries

### State Management

**Backend State:**
```
┌──────────────────┐
│   PostgreSQL     │
│                  │
│ - Influencers    │ (Core entities)
│ - Calls          │ (Extracted calls)
│ - PriceSnapshots │ (Historical prices)
│ - ContentSources │ (YouTube/Twitter links)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Redis          │ (Optional)
│                  │
│ - Job queue      │ (If using Sidekiq)
│ - Rate limits    │ (API throttling)
│ - API cache      │ (Short-lived responses)
└──────────────────┘
```

**Frontend State:**
```
┌──────────────────┐
│  React State     │
│                  │
│ - Selected       │ (Local UI state)
│   influencer     │
│ - Timeframe      │
│ - Chart zoom     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  SWR/TanStack    │
│  Query Cache     │
│                  │
│ - Chart data     │ (Server state cache)
│ - Influencers    │
└──────────────────┘
```

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| **0-100 users** | Monolithic Rails + Next.js, single PostgreSQL instance, no Redis needed (use Solid Queue), batch processing every hour, single worker process |
| **100-10K users** | Add Redis for caching frequently accessed chart data, increase worker count for parallel job processing, implement database connection pooling, add CDN for Next.js static assets, consider read replicas for heavy queries |
| **10K-100K users** | Separate job processing to dedicated worker nodes, implement database sharding by influencer_id, add Elasticsearch for full-text search on calls, use WebSocket or Server-Sent Events for real-time updates, implement aggressive caching with 5-15 minute TTL on chart data |
| **100K+ users** | Split services: Content Ingestion Service, Call Extraction Service, Price Service, consider Kafka for event streaming instead of database polling, implement time-series database (TimescaleDB) for price data, add GraphQL API for flexible frontend queries, consider microservices architecture with API gateway |

### Scaling Priorities

1. **First bottleneck: Database queries for chart data**
   - **Problem**: Joining calls + price_snapshots on every request is expensive
   - **Fix**: Materialize chart data into pre-aggregated tables, use PostgreSQL partial indexes on `(influencer_id, timestamp)`, cache responses at API layer with 5-10 minute TTL

2. **Second bottleneck: Background job queue saturation**
   - **Problem**: Processing 100+ videos per influencer per day overwhelms single worker
   - **Fix**: Horizontal scaling of workers (Railway supports this), prioritize recent content over backfill, implement job priority queues (real-time tweets > hourly videos)

3. **Third bottleneck: Transcription API rate limits**
   - **Problem**: OpenAI Whisper API has rate limits; hitting limits delays all processing
   - **Fix**: Implement exponential backoff with retry, batch process videos by priority (recent first), consider self-hosting Whisper for high volume, cache transcriptions permanently

## Anti-Patterns

### Anti-Pattern 1: Tight Coupling to External APIs

**What people do:** Directly call YouTube/Twitter/price APIs from controllers or models without abstraction

**Why it's wrong:** When APIs change (rate limits, response format, deprecation), code breaks in multiple places; testing becomes difficult without hitting real APIs; can't easily swap providers

**Do this instead:** Use the Adapter pattern to isolate external API dependencies; create service objects to orchestrate API calls; inject adapters into services for testability

**Example of anti-pattern:**
```ruby
# BAD: Controller directly calls API
class Api::V1::ChartsController < ApplicationController
  def show
    influencer = Influencer.find(params[:id])

    # Direct API call in controller
    response = HTTParty.get("https://api.coingecko.com/api/v3/coins/bitcoin/ohlc")
    price_data = response.parsed_response

    render json: { influencer: influencer, prices: price_data }
  end
end
```

**Example of correct pattern:**
```ruby
# GOOD: Service + Adapter pattern
class Api::V1::ChartsController < ApplicationController
  def show
    chart_data = ChartBuilder::OverlayService.new(
      influencer_id: params[:id],
      price_adapter: PriceAdapterRegistry.get(:coingecko)
    ).build

    render json: chart_data
  end
end
```

### Anti-Pattern 2: Synchronous Processing in HTTP Requests

**What people do:** Transcribe videos, extract calls, and fetch price data synchronously during API requests

**Why it's wrong:** User waits 30+ seconds for response; request times out; server resources locked during long operations; single failed step blocks entire flow

**Do this instead:** Queue all expensive operations as background jobs; return 202 Accepted immediately; poll for completion or use webhooks to notify frontend

**Example of anti-pattern:**
```ruby
# BAD: Synchronous processing
class Api::V1::InfluencersController < ApplicationController
  def sync_content
    influencer = Influencer.find(params[:id])

    # Blocks for 30+ seconds
    videos = YoutubeAPI.fetch_videos(influencer.channel_id)
    videos.each do |video|
      transcript = WhisperAPI.transcribe(video.audio_url)  # 10-20 seconds each
      calls = NlpExtractor.extract(transcript)             # 5 seconds each
      calls.each { |call| Call.create!(call) }
    end

    render json: { status: 'complete' }  # User waited 5+ minutes
  end
end
```

**Example of correct pattern:**
```ruby
# GOOD: Async job chain
class Api::V1::InfluencersController < ApplicationController
  def sync_content
    influencer = Influencer.find(params[:id])
    ProcessYoutubeChannelJob.perform_later(influencer.id)

    render json: { status: 'queued', job_id: ProcessYoutubeChannelJob.job_id }, status: 202
  end
end
```

### Anti-Pattern 3: Storing All Price Data at Maximum Granularity

**What people do:** Store 1-second or 1-minute price data for every coin indefinitely

**Why it's wrong:** Database grows exponentially; queries become slow; most users don't need second-level precision for historical data; expensive storage costs

**Do this instead:** Use tiered storage: 1-minute granularity for last 7 days, 1-hour for last 30 days, 1-day for older data; implement data retention policies; aggregate old data into larger intervals

**Example of anti-pattern:**
```ruby
# BAD: Storing every 1-minute tick forever
class FetchPriceDataJob < ApplicationJob
  def perform(coin, start_time, end_time)
    (start_time..end_time).step(1.minute).each do |timestamp|
      price = PriceAdapter.fetch_at(coin, timestamp)
      PriceSnapshot.create!(coin: coin, timestamp: timestamp, price: price, interval: '1m')
    end
  end
end
# Result: Millions of rows for single coin over 1 year
```

**Example of correct pattern:**
```ruby
# GOOD: Tiered storage with aggregation
class FetchPriceDataJob < ApplicationJob
  def perform(coin, timestamp)
    # Store 1-hour data for display (sufficient for most charts)
    hourly_ohlcv = PriceAdapter.fetch_ohlcv(coin, timestamp - 1.hour, timestamp + 24.hours, interval: '1h')
    hourly_ohlcv.each do |bar|
      PriceSnapshot.upsert(coin: coin, timestamp: bar[:time], interval: '1h', **bar)
    end
  end
end

# Cleanup job runs monthly
class AggregateOldPriceDataJob < ApplicationJob
  def perform
    # Aggregate 1-hour bars older than 30 days into 1-day bars
    old_bars = PriceSnapshot.where(interval: '1h', timestamp: ..30.days.ago)
    old_bars.group_by_day(:timestamp).each do |day, bars|
      PriceSnapshot.create!(
        coin: bars.first.coin,
        timestamp: day,
        interval: '1d',
        open: bars.first.open,
        high: bars.maximum(:high),
        low: bars.minimum(:low),
        close: bars.last.close,
        volume: bars.sum(:volume)
      )
    end
    old_bars.delete_all
  end
end
```

### Anti-Pattern 4: Not Validating Extracted Calls

**What people do:** Trust LLM/NLP output without validation; save every extracted entity as a call

**Why it's wrong:** LLMs hallucinate; false positives clutter charts; invalid coin symbols break price fetching; reduces user trust

**Do this instead:** Implement validation layer after extraction; verify coin symbols against known list; require minimum confidence score; flag low-confidence calls for manual review

**Example of anti-pattern:**
```ruby
# BAD: Trust LLM output blindly
class CallExtraction::NlpExtractorService
  def extract_calls(transcript)
    response = OpenAI.chat(prompt: build_prompt(transcript))
    calls = JSON.parse(response)

    calls.each do |call_data|
      Call.create!(call_data)  # No validation
    end
  end
end
```

**Example of correct pattern:**
```ruby
# GOOD: Validate before creating
class CallExtraction::NlpExtractorService
  def extract_calls(transcript)
    response = OpenAI.chat(prompt: build_prompt(transcript))
    raw_calls = JSON.parse(response)

    raw_calls.filter_map do |call_data|
      validated = CallValidatorService.new(call_data).validate
      Call.create!(validated) if validated
    end
  end
end

class CallExtraction::CallValidatorService
  VALID_COINS = %w[BTC ETH SOL BNB ADA DOT LINK MATIC AVAX].freeze

  def initialize(call_data)
    @call_data = call_data
  end

  def validate
    return nil unless valid_coin?
    return nil unless valid_direction?
    return nil unless valid_timestamp?
    return nil unless meets_confidence_threshold?

    @call_data
  end

  private

  def valid_coin?
    VALID_COINS.include?(@call_data[:coin]&.upcase)
  end

  def valid_direction?
    %w[long short].include?(@call_data[:direction]&.downcase)
  end

  def valid_timestamp?
    @call_data[:timestamp].present? && @call_data[:timestamp] < Time.current
  end

  def meets_confidence_threshold?
    (@call_data[:confidence] || 0) >= 0.7
  end
end
```

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| **YouTube Data API v3** | REST API via adapter, OAuth 2.0 auth | Rate limit: 10,000 units/day; batch requests when possible; cache channel metadata |
| **Twitter API v2** | REST API via adapter, Bearer token auth | Rate limit: 300 requests/15min for user timeline; consider webhook subscription for real-time |
| **OpenAI Whisper API** | REST API, multipart audio upload | Rate limit: 50 requests/min; supports multiple audio formats; ~$0.006/minute |
| **OpenAI GPT-4 API** | REST API, JSON mode for extraction | Rate limit: 10,000 tokens/min; use structured outputs for reliable parsing; ~$0.03/1K tokens |
| **CoinGecko API** | REST API via adapter, API key optional | Rate limit: 10-30 calls/min on free tier; Pro tier recommended for production; reliable historical data |
| **Binance API** | REST API via adapter, API key + signature | Rate limit: 1200 requests/min; excellent for real-time prices; limited historical data |
| **TradingView Charting Library** | JavaScript library, datafeed interface | Requires datafeed implementation; supports real-time updates via WebSocket; free for non-commercial |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| **Next.js ↔ Rails API** | HTTP REST (JSON) | Authenticate via JWT; use versioned endpoints (/api/v1); consider GraphQL for complex queries |
| **Rails API ↔ Background Jobs** | Database queue (Solid Queue) | Jobs communicate via shared database; use job arguments for parameters; avoid large payloads |
| **Services ↔ Adapters** | Direct method calls (dependency injection) | Adapters registered in initializer; services receive adapter instances; swap adapters via config |
| **Background Jobs ↔ External APIs** | HTTP requests via adapters | Implement exponential backoff; log all external requests; respect rate limits per provider |
| **Frontend ↔ TradingView Library** | JavaScript datafeed interface | Implement `onReady`, `resolveSymbol`, `getBars` methods; return data in TradingView format |

### Build Dependencies

**Phase 1: Foundation (Backend Core)**
- PostgreSQL schema (influencers, calls, price_snapshots)
- Rails API endpoints (CRUD for entities)
- Basic Next.js pages (influencer list, detail)
- **Blocks**: All other phases depend on this

**Phase 2: Content Ingestion (YouTube)**
- YouTube adapter + ingestor service
- Background job infrastructure (Solid Queue)
- Scheduled jobs for hourly sync
- **Depends on**: Phase 1 (database schema)
- **Blocks**: Phase 3 (needs content to extract calls from)

**Phase 3: Call Extraction**
- Transcription service (Whisper integration)
- NLP extractor service (GPT-4 integration)
- Call validation service
- **Depends on**: Phase 2 (needs content), Phase 1 (needs database)
- **Blocks**: Phase 4 (needs calls to overlay on charts)

**Phase 4: Price Data Integration**
- Price adapter pattern implementation
- CoinGecko adapter
- Price fetcher service
- **Depends on**: Phase 1 (needs database)
- **Blocks**: Phase 5 (needs price data for charts)

**Phase 5: Chart Rendering**
- TradingView integration
- Chart builder service
- Overlay formatting
- **Depends on**: Phase 3 (needs calls), Phase 4 (needs prices)
- **Blocks**: None (final user-facing feature)

**Optional Future Phases:**
- **Real-time Twitter monitoring**: Depends on Phase 3
- **Multiple price adapter support**: Extends Phase 4
- **User authentication & portfolios**: Parallel to all phases
- **Performance alerts**: Depends on Phase 5

## Sources

### Architecture & System Design
- [Social Media Feed System Design](https://javatechonline.com/social-media-feed-system-design/)
- [Real-Time Data Pipelines: Design Patterns](https://www.landskill.com/blog/real-time-data-pipelines-patterns/)
- [Streaming Data Pipeline Architecture](https://www.acceldata.io/blog/mastering-streaming-data-pipelines-for-real-time-data-processing)
- [Processing Billions of Events at Twitter](https://blog.x.com/engineering/en_us/topics/infrastructure/2021/processing-billions-of-events-in-real-time-at-twitter-)

### Rails & Background Jobs
- [Active Job Basics — Ruby on Rails Guides](https://guides.rubyonrails.org/active_job_basics.html)
- [GoodJob: Postgres-based Active Job backend](https://github.com/bensheldon/good_job)
- [Background Jobs and Task Scheduling in Rails](https://www.railscarma.com/blog/background-jobs-and-task-scheduling-in-ruby-on-rails/)

### Next.js & Rails Integration
- [Building a BFF Architecture with Next.js](https://vishal-vishal-gupta48.medium.com/building-a-secure-scalable-bff-backend-for-frontend-architecture-with-next-js-api-routes-cbc8c101bff0)
- [Rails and Next.js: Perfect Combination for Modern Web Development](https://medium.com/@raphox/rails-and-next-js-the-perfect-combination-for-modern-web-development-part-2-308d2f41a767)
- [Backend for Frontend | Next.js Guides](https://nextjs.org/docs/app/guides/backend-for-frontend)

### Adapter Pattern & API Integration
- [Adapter Pattern in Microservice Architectures](https://medium.com/@jescrich_57703/harnessing-the-adapter-pattern-in-microservice-architectures-for-vendor-agnosticism-debc21d2fe21)
- [Adapter Design Pattern for Third-Party Integrations](https://medium.com/@olorondu_emeka/adapter-design-pattern-a-guide-to-manage-multiple-third-party-integrations-dc342f435daf)
- [Hexagonal Architecture Pattern — AWS](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html)

### Cryptocurrency APIs
- [Best Real-Time Crypto Price APIs in 2026](https://coinranking.com/blog/best-real-time-crypto-price-apis-in-2026-a-developer-guide/)
- [CoinGecko Crypto Data API](https://www.coingecko.com/en/api)
- [CoinAPI Market Data API](https://www.coinapi.io/products/market-data-api)
- [Best Crypto WebSocket APIs (2026)](https://www.coingecko.com/learn/top-5-best-crypto-websocket-apis)

### Video Transcription & NLP
- [AI Call Transcription Systems: Complete Guide 2026](https://smith.ai/blog/ai-call-transcription-systems)
- [NLP Pipeline: Key Steps to Process Text Data](https://airbyte.com/data-engineering-resources/natural-language-processing-pipeline)
- [Natural Language Processing (NLP) Pipeline](https://www.geeksforgeeks.org/nlp/natural-language-processing-nlp-pipeline/)

### TradingView Integration
- [TradingView Charting Library: Empowering Developers](https://pineify.app/resources/blog/tradingview-charting-library-empowering-developers-with-advanced-financial-visualization)
- [TradingView Advanced Charts](https://www.tradingview.com/advanced-charts/)
- [B2BROKER TradingView Integration Announcement](https://www.globenewswire.com/news-release/2026/01/15/3219401/0/en/B2BROKER-Brings-TradingView-Integration-into-B2TRADER-to-Connect-Brokers-with-Global-Markets.html)

---
*Architecture research for: Influencer/Financial Call Tracking Platform*
*Researched: 2026-02-05*
