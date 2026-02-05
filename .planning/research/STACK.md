# Stack Research

**Domain:** Influencer/Financial Call Tracking Platform
**Researched:** 2026-02-05
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Ruby on Rails | 8.1.2 | Backend API framework | Rails 8.1.2 (released Jan 2026) brings built-in authentication, improved deployment with Kamal, and Solid Cable for WebSockets. Rails excels at rapid API development with ActiveRecord ORM and built-in background jobs via ActiveJob. |
| Ruby | 3.4.x | Programming language | Ruby 3.4 is the latest stable version with support until March 2028. Offers performance improvements over 3.3 and full Rails 8 compatibility. Rails 8 requires Ruby 3.2.0+. |
| PostgreSQL | 16.x | Primary database | Industry-standard relational database. Rails 8 supports advanced PG features (CTEs, window functions, JSONB, full-text search). Railway offers managed PostgreSQL with simple provisioning. |
| Next.js | 16.1.2 | Frontend framework | Next.js 16 (latest as of Feb 2026) brings improved routing, caching, and Turbopack in beta. Server components reduce bundle size. App Router pattern ideal for authenticated dashboards. |
| React | 19.x | UI library | Required by Next.js 16. React 19 removes forward refs (better DX) and improves concurrent rendering for smoother chart interactions. |
| TypeScript | 5.x | Type system | Essential for Next.js projects. Catches bugs at compile time, especially important for financial data handling and API contracts. |

### Supporting Libraries - Backend (Rails)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Sidekiq | 8.x | Background job processing | Required for async content ingestion (YouTube/Twitter) and transcription. Uses Redis for queue management. Rails 8 integrates via ActiveJob. |
| Redis | 7.2.4+ | In-memory data store | Required by Sidekiq for job queues. Also useful for rate limiting API calls and caching API responses (YouTube/Twitter quotas). |
| pg | 1.x | PostgreSQL adapter | Required for ActiveRecord to connect to PostgreSQL. Comes with Rails by default when using --database=postgresql. |
| devise OR rails_auth | latest | Authentication | Rails 8 ships with built-in authentication generator (rails_auth). For invite-only system, built-in auth is sufficient. Use Devise only if you need OAuth or complex features. **Recommendation: Start with Rails 8 built-in auth.** |
| pundit | 2.x | Authorization | Lightweight policy-based authorization. Perfect for admin vs. user permissions and invite-only access control. |
| rack-cors | 2.x | CORS middleware | Required for Next.js frontend to communicate with Rails API backend. Configure allowed origins for security. |
| jwt | 2.x | JSON Web Tokens | For stateless authentication between Next.js and Rails. Alternative to session-based auth for API-only backends. |
| httparty OR faraday | latest | HTTP client | For calling external APIs (YouTube Data API v3, X API v2, OpenAI Whisper, CoinGecko). Faraday is more modern with middleware support. |
| yt-dlp (system) | 2026.01.31 | YouTube audio extraction | Command-line tool (not gem). More actively maintained than youtube-dl. Required to download audio for transcription. Install via system package manager. |

### Supporting Libraries - Frontend (Next.js)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| @tanstack/react-query | 5.90.19 | Server state management | Essential for managing API calls to Rails backend. Handles caching, refetching, and optimistic updates. Better than plain fetch for real-time data. |
| lightweight-charts | 5.1.0 | TradingView-style charts | Official TradingView library. Only 35KB, performs well with thousands of data points. Apache 2.0 license allows commercial use. Perfect for overlaying calls on price charts. |
| tailwindcss | 4.x | CSS framework | Next.js standard. Utility-first CSS for rapid UI development. Works seamlessly with shadcn/ui components. |
| shadcn/ui | latest | Component library | Copy-paste components (not npm package). Built on Radix UI + Tailwind. Use for dashboard, forms, modals. Now supports Tailwind v4 and React 19. |
| axios OR ky | latest | HTTP client | Alternative to fetch for cleaner API calls. Axios is more common, ky is more modern. Use with TanStack Query for best results. |
| zod | latest | Schema validation | Runtime validation for API responses from Rails. Ensures type safety and catches malformed data. Works well with TypeScript. |
| next-auth | 4.x or 5.x beta | Authentication | If using OAuth/SSO. For simple JWT auth with Rails, manual implementation might be lighter. Optional: only if complex auth flows needed. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Railway CLI | Deployment orchestration | Deploy Rails backend + PostgreSQL + Redis to Railway. Built-in support for Dockerfile (Rails 8 includes Dockerfile by default). |
| Vercel CLI | Frontend deployment | Deploy Next.js to Vercel (edge network). Free tier suitable for invite-only MVP. Alternative: Railway can also host Next.js. |
| rubocop | Ruby linting | Standard Ruby style checker. Enforces community best practices. |
| prettier | JS/TS formatting | Auto-format Next.js code. Works with ESLint for consistent style. |
| rspec | Rails testing | BDD framework for Rails. Better readability than Minitest for complex business logic (call extraction). |
| jest + testing-library | Next.js testing | Standard React testing stack. Use for component tests and integration tests. |

## Installation

### Backend (Rails)

```bash
# Create new Rails 8 API with PostgreSQL
rails new influenza-api --api --database=postgresql

# Core gems (add to Gemfile)
gem 'sidekiq', '~> 8.0'
gem 'redis', '~> 7.2'
gem 'pundit', '~> 2.3'
gem 'rack-cors', '~> 2.0'
gem 'jwt', '~> 2.8'
gem 'httparty', '~> 0.21'

# Dev dependencies
group :development, :test do
  gem 'rspec-rails', '~> 7.0'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.4'
end

# Install
bundle install

# Add Sidekiq to config/application.rb
config.active_job.queue_adapter = :sidekiq

# Install yt-dlp (system-level)
# macOS:
brew install yt-dlp
# Linux:
pip install yt-dlp
```

### Frontend (Next.js)

```bash
# Create Next.js 16 with TypeScript
npx create-next-app@latest influenza-frontend --typescript --tailwind --app

# Core dependencies
npm install @tanstack/react-query lightweight-charts zod axios

# UI components (shadcn/ui - requires initialization)
npx shadcn@latest init
# Then add components as needed:
npx shadcn@latest add button card chart dialog

# Dev dependencies
npm install -D prettier eslint-config-prettier @testing-library/react @testing-library/jest-dom jest
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Rails 8.1.2 | FastAPI (Python) | If team has stronger Python expertise. Python ecosystem better for ML/data science. However, Rails is more mature for CRUD APIs. |
| Next.js 16 | Remix | If you prefer Remix's loader/action pattern over Server Components. Remix has better form handling. Next.js has larger ecosystem. |
| PostgreSQL | MySQL | Only if you already have MySQL infrastructure. PostgreSQL has better JSON support (JSONB) for storing unstructured API responses. |
| Sidekiq | Solid Queue (Rails 8) | Solid Queue is new in Rails 8, uses DB instead of Redis. Use if you want zero Redis dependency. Sidekiq is battle-tested and faster. |
| TanStack Query | SWR | SWR is simpler, good for basic fetching. TanStack Query has more features (mutations, pagination, optimistic updates) needed for dashboards. |
| lightweight-charts | Recharts | Recharts is React-native with simpler API. Use for static charts. lightweight-charts handles real-time updates and thousands of data points better. |
| Built-in Rails Auth | Devise | Devise if you need OAuth, email confirmation, password reset out-of-box. Rails 8 auth is lighter and more customizable for invite-only systems. |
| JWT | Session cookies | Sessions if Next.js and Rails share same domain. JWT if Next.js is on different domain (e.g., Vercel) for stateless auth. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| youtube-dl | Unmaintained since 2021, broken with recent YouTube changes | yt-dlp (active fork with weekly updates) |
| Twitter API v1.1 | Deprecated, limited access | X API v2 or third-party scrapers (note: X API pricing is $100-$42k/month) |
| Rails < 8.0 | Missing built-in auth, Solid adapters, and performance improvements | Rails 8.1.2 |
| Next.js Pages Router | Deprecated in favor of App Router. No Server Components support. | Next.js App Router (default in 16.x) |
| GraphQL | Adds complexity for simple CRUD operations. Overkill for this use case. | REST API with JSON (Rails default) |
| MongoDB | Rails ORM (ActiveRecord) is built for SQL. Schema-less not needed for this domain. | PostgreSQL with JSONB for flexibility |
| Create React App | Deprecated, no longer maintained | Next.js or Vite |
| Redux | Overengineered for API state. Most state is server state (calls, prices). | TanStack Query for server state + React Context for UI state |

## Stack Patterns by Variant

### If Budget is ZERO (Free Tier Only):
- **Price data:** CoinGecko Free API (30 calls/min, 10k/month)
- **Transcription:** Run Whisper locally (open source, no API costs)
- **Deployment:** Railway free tier ($5 credit/month) + Vercel free tier
- **Skip:** OpenAI Whisper API ($0.006/min of audio adds up quickly)

### If Scaling Beyond MVP (>100 users):
- **Price data:** Upgrade to CoinGecko Analyst ($130/month) or switch to Messari
- **Transcription:** OpenAI Whisper API (faster than local, $0.006/min is ~$6/hour of content)
- **Job processing:** Scale Sidekiq workers horizontally on Railway
- **Caching:** Add Redis caching layer for API responses to reduce external API calls

### If Privacy is Critical (No Third-Party APIs):
- **Transcription:** Self-host Whisper.cpp or Faster-Whisper on Railway
- **Price data:** Ingest directly from exchange WebSockets (Binance, Coinbase)
- **Content:** Store raw transcripts locally, avoid sending to OpenAI for call extraction
- **LLM:** Self-host Llama 3.3 or Mixtral for sentiment analysis

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| Rails 8.1.2 | Ruby 3.2.0+ | Ruby 3.4 recommended for longest support (until March 2028) |
| Rails 8.1.2 | PostgreSQL 9.3+ | PostgreSQL 16+ recommended for full feature support (JSONB, window functions) |
| Sidekiq 8.x | Redis 7.2.4+ | Redis 7.0+ works, 7.2.4+ recommended. Also supports Valkey and Dragonfly as Redis alternatives. |
| Next.js 16 | React 19 | React 19 required (auto-installed). React 18 not compatible. |
| shadcn/ui | Tailwind 4.x | Recent update (Jan 2026) adds Tailwind v4 support. Use tw-animate-css instead of tailwindcss-animate. |
| lightweight-charts 5.1.0 | React 18+ | Use lightweight-charts-react-wrapper for easier React integration |
| TanStack Query 5.x | Next.js 13+ | Supports App Router Server Components via prefetching and hydration patterns |

## Content Processing Architecture

### YouTube Pipeline:
1. **Audio extraction:** yt-dlp (system command via Sidekiq job) → saves .mp3 to temp storage
2. **Transcription:** OpenAI Whisper API (gpt-4o-transcribe model) OR local Whisper → JSON with timestamps
3. **Call extraction:** GPT-4o (Claude Sonnet 4.5 is more expensive, 1.2x input / 1.5x output) → structured JSON with sentiment
4. **Storage:** PostgreSQL with JSONB for raw transcript + extracted calls

### X/Twitter Pipeline:
1. **Content scraping:** X API v2 ($100/month Basic plan for 10k reads) OR third-party scraper (Apify, Scrapingdog ~$0.0009/record)
2. **Parsing:** Ruby regex or GPT-4o-mini for extracting ticker symbols and directional language
3. **Call extraction:** Same LLM pipeline as YouTube (cheaper for short text)
4. **Rate limiting:** Redis cache to avoid re-processing same tweets

### Price Data Pipeline:
1. **Free tier:** CoinGecko API (30 calls/min) → cache aggressively in Redis
2. **Modular adapter pattern:**
```ruby
# app/services/price_adapters/base.rb
class PriceAdapters::Base
  def fetch_historical(symbol, start_date, end_date)
    raise NotImplementedError
  end
end

# app/services/price_adapters/coingecko.rb
class PriceAdapters::Coingecko < PriceAdapters::Base
  def fetch_historical(symbol, start_date, end_date)
    # CoinGecko API logic
  end
end

# app/services/price_adapters/messari.rb (future upgrade)
class PriceAdapters::Messari < PriceAdapters::Base
  def fetch_historical(symbol, start_date, end_date)
    # Messari API logic
  end
end
```

## Deployment Architecture

### Railway (Backend):
```yaml
# railway.json
{
  "build": {
    "builder": "DOCKERFILE"
  },
  "deploy": {
    "startCommand": "bundle exec rails server -b 0.0.0.0 -p $PORT",
    "restartPolicyType": "ON_FAILURE"
  }
}
```
- **Main service:** Rails API (port 3000)
- **Worker service:** Sidekiq (same codebase, different start command: `bundle exec sidekiq`)
- **Database:** PostgreSQL plugin (auto-provisions)
- **Cache:** Redis plugin (auto-provisions)
- **Environment variables:** Set via Railway UI (RAILS_MASTER_KEY, API keys, CORS origins)

### Vercel (Frontend):
- **Next.js 16** auto-detects and deploys
- **Environment variables:** NEXT_PUBLIC_API_URL (points to Railway API)
- **Edge runtime:** Use for API routes if needed (e.g., proxying sensitive API keys)

## API Integration Best Practices

### YouTube Data API v3:
- **Quota:** 10,000 units/day by default (video metadata ~5 units, uploads list ~100 units)
- **Rate limiting:** Implement exponential backoff for quota errors
- **Transcripts:** Use youtube-transcript-api (Python) or parse community captions via API
- **Caveat:** Transcripts via API consume quota. Alternative: yt-dlp extracts audio → Whisper transcription (no quota, but costs compute/API)

### X/Twitter API v2:
- **Free tier:** Write-only (1,500 tweets/month) - NOT useful for reading influencer content
- **Basic ($100/mo):** 10,000 reads/month at app level
- **Reality check:** Basic tier is minimum for production. For MVP, consider third-party scrapers to avoid $100/month cost.
- **Alternative:** Apify Tweet Scraper ($49/month for 100k tweets) or DIY scraper (high maintenance, breaks every 2-4 weeks)

### OpenAI Whisper API:
- **Pricing:** $0.006 per minute of audio (~$6/hour of content)
- **Models:** gpt-4o-transcribe (best), whisper-1 (cheaper, good enough for MVP)
- **Format support:** mp3, mp4, wav, flac (yt-dlp outputs mp3 by default)
- **Diarization:** gpt-4o-transcribe-diarize (speaker identification) - useful if multiple people on call

### CoinGecko API:
- **Free tier:** 30 calls/min, 10,000 calls/month (no API key required)
- **Rate limiting:** Implement client-side throttling + Redis cache
- **Endpoints:**
  - `/simple/price` - Real-time prices (use for chart endpoint updates)
  - `/coins/{id}/market_chart` - Historical data (use for initial chart load)
- **Caching strategy:** Cache historical data aggressively (immutable), real-time data for 1-5 min

## LLM Call Extraction Strategy

### Prompt Engineering for Financial Calls:

**Input:** Transcript segment (YouTube) or tweet text

**Output:** Structured JSON:
```json
{
  "calls": [
    {
      "asset": "BTC",
      "direction": "bullish" | "bearish" | "neutral",
      "confidence": 0.0-1.0,
      "price_target": 50000.00 | null,
      "timeframe": "short" | "medium" | "long" | null,
      "timestamp": "2026-02-05T14:30:00Z",
      "quote": "I think Bitcoin is going to 50k this week"
    }
  ]
}
```

### Model Selection:
- **GPT-4o:** Good balance of cost ($2.50/1M input tokens) and accuracy. Best for production.
- **GPT-4o-mini:** Cheaper ($0.15/1M input tokens). Use for tweet parsing (short text).
- **Claude Sonnet 4.5:** Higher accuracy on finance benchmarks (55.32% vs GPT-5.1's 56.55%) but 1.2-1.5x more expensive. Consider for critical calls.
- **Local Llama 3.3:** Free but requires hosting. Use if privacy > convenience.

### Confidence Strategy:
- **High confidence (>0.8):** Display prominently on chart
- **Medium (0.5-0.8):** Display with lower opacity
- **Low (<0.5):** Store in DB but don't display (useful for later analysis)

## Sources

### Official Documentation & Releases:
- [Rails 8.1.2 Release](https://rubyonrails.org/2026/1/22/rails-version-8-1-2-has-been-released) - Latest Rails version
- [Rails 8.0 Release Notes](https://guides.rubyonrails.org/8_0_release_notes.html) - New features
- [Next.js 16 Release](https://nextjs.org/blog/next-15) - Framework updates (note: search found 16.1.2 on npm)
- [Next.js 15.5](https://nextjs.org/blog/next-15-5) - Recent updates
- [PostgreSQL Versioning Policy](https://www.postgresql.org/support/versioning/) - Support timeline
- [Ruby & Rails Compatibility](https://www.fastruby.io/blog/ruby/rails/versions/compatibility-table.html) - Version matrix
- [TradingView Lightweight Charts](https://www.tradingview.com/lightweight-charts/) - Official docs
- [Lightweight Charts GitHub](https://github.com/tradingview/lightweight-charts) - Open source repo
- [OpenAI Whisper API](https://platform.openai.com/docs/guides/speech-to-text) - Transcription docs
- [CoinGecko API](https://www.coingecko.com/en/api) - Price data API

### Architecture & Integration:
- [Railway Rails Deployment](https://docs.railway.com/guides/rails) - Official guide
- [Railway Best Practices](https://docs.railway.com/overview/best-practices) - Deployment patterns
- [Next.js Authentication](https://nextjs.org/docs/pages/guides/authentication) - Auth patterns
- [TanStack Query with Next.js](https://tanstack.com/query/latest/docs/framework/react/examples/nextjs) - Integration examples
- [shadcn/ui Next.js](https://ui.shadcn.com/docs/installation/next) - Component setup
- [Sidekiq GitHub](https://github.com/sidekiq/sidekiq) - Background jobs

### API & Data Sources:
- [YouTube API Reference](https://developers.google.com/youtube/v3/docs) - Official docs
- [Best YouTube Transcript APIs](https://supadata.ai/blog/best-youtube-transcript-api) - Comparison
- [yt-dlp GitHub](https://github.com/yt-dlp/yt-dlp) - YouTube downloader
- [X/Twitter Scraping 2026](https://www.rapidseedbox.com/blog/mastering-twitter-scraping) - API alternatives
- [CoinGecko Pricing](https://www.coingecko.com/en/api/pricing) - Tier comparison

### Benchmarks & Comparisons:
- [Ruby 3.4 Rails 8 Compatibility](https://www.fastruby.io/blog/ruby/rails/versions/compatibility-table.html) - Version support
- [Rails 8 Authentication Options](https://blog.nonstopio.com/rails-8-authentication-devise-vs-clearance-vs-built-in-options-2169e91e8bcc) - Auth comparison
- [Next.js 16 + React Query Guide](https://medium.com/@bendesai5703/next-js-16-react-query-the-ultimate-guide-to-modern-data-fetching-caching-performance-ac13a62d727d) - Integration patterns
- [Claude Sonnet 4.5 vs GPT-4o Finance](https://www.vals.ai/benchmarks/finance_agent) - LLM benchmarks
- [Deploying Full Stack Apps 2026](https://www.nucamp.co/blog/deploying-full-stack-apps-in-2026-vercel-netlify-railway-and-cloud-options) - PaaS comparison

---
*Stack research for: Influencer/Financial Call Tracking Platform*
*Researched: 2026-02-05*
*Confidence: HIGH - All versions verified via official sources and recent web search (Feb 2026)*
