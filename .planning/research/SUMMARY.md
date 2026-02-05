# Project Research Summary

**Project:** Influenza - Influencer/Financial Call Tracking Platform
**Domain:** Financial/Crypto Analytics & Social Media Monitoring
**Researched:** 2026-02-05
**Confidence:** HIGH

## Executive Summary

Influenza is an influencer call tracking platform that visualizes when crypto/finance influencers make trading recommendations and overlays those "calls" on price charts. This domain sits at the intersection of social media monitoring, NLP extraction, and financial data visualization. The core value proposition is simple but powerful: show users exactly when an influencer said "buy Bitcoin" and what the price did afterward.

The recommended approach is a Rails 8 API backend with Next.js 16 frontend, leveraging TradingView's Lightweight Charts for visualization. The technical challenge centers on reliable content ingestion (YouTube + Twitter APIs with strict rate limits) and accurate call extraction (NLP/LLM-based with 40-60% false positive risk). Start with admin-curated influencers (5-10) and batch processing (every 15-30 min) to manage API quotas and complexity. The chart overlay is the killer feature - invest heavily in visualization quality while deferring accuracy scoring and social features to V2+.

Key risks include YouTube API quota exhaustion (10K units/day burns fast), false positive call extraction (requires negation detection and confidence scoring), and timestamp synchronization nightmares (multiple timezone sources). Mitigation: implement quota monitoring from day one, use multi-stage NLP validation with confidence thresholds, and enforce strict UTC storage with timezone conversion. The research shows this is a less mature space than stock analyst tracking (TipRanks), which works in our favor - users don't expect real-time data or comprehensive accuracy metrics initially.

## Key Findings

### Recommended Stack

Rails 8.1.2 with Ruby 3.4 provides built-in authentication, Solid Queue for background jobs, and excellent API development ergonomics. Next.js 16 with React 19 delivers server components for optimal performance and pairs naturally with TradingView's Lightweight Charts library. PostgreSQL 16 handles structured data (influencers, calls, price snapshots) with JSONB support for flexible API response storage.

**Core technologies:**
- **Rails 8.1.2 + Ruby 3.4**: Backend API framework - ships with built-in auth, Solid Queue for background jobs, ActiveRecord ORM for rapid development. Rails excels at CRUD APIs and background processing.
- **Next.js 16 + React 19**: Frontend framework - App Router with server components reduces bundle size, perfect for authenticated dashboards. React 19 improves concurrent rendering for smooth chart interactions.
- **PostgreSQL 16**: Primary database - industry-standard relational DB with advanced features (JSONB, window functions, full-text search). Railway offers managed hosting with simple provisioning.
- **TradingView Lightweight Charts 5.1.0**: Chart library - only 35KB, handles thousands of data points, Apache 2.0 license. Industry standard for financial visualization with call overlay support.
- **Sidekiq 8 + Redis 7.2.4**: Background job processing - required for async content ingestion and transcription. Alternative: Rails 8 Solid Queue (DB-based, no Redis dependency).
- **OpenAI Whisper API**: Transcription - gpt-4o-transcribe model at $0.006/min. Alternative: self-host Whisper for zero API costs but higher compute requirements.
- **GPT-4o**: Call extraction - $2.50/1M input tokens, good balance of cost and accuracy. Use GPT-4o-mini ($0.15/1M tokens) for tweet parsing.
- **CoinGecko Free API**: Price data - 30 calls/min, 10K/month free tier. Sufficient for MVP with aggressive caching. Upgrade to Analyst tier ($130/month) for production.

**Critical version requirements:**
- Rails 8 requires Ruby 3.2.0+ (use 3.4 for longest support until March 2028)
- Next.js 16 requires React 19 (auto-installed, not backward compatible with 18)
- Sidekiq 8 requires Redis 7.2.4+ (or use Rails 8 Solid Queue to avoid Redis)

**What NOT to use:**
- youtube-dl (unmaintained since 2021) - use yt-dlp instead
- Twitter API v1.1 (deprecated) - use X API v2
- GraphQL (overcomplicated for simple CRUD) - stick with REST
- MongoDB (poor Rails integration) - use PostgreSQL with JSONB for flexibility

### Expected Features

Research reveals this is a less mature space than professional analyst tracking, which lowers the bar for MVP. Users don't expect real-time updates (batch every 15-30 min is fine) or comprehensive accuracy scoring (visual comparison sufficient initially).

**Must have (table stakes):**
- **Price chart visualization**: TradingView-style interactive charts are the standard - candlestick/line charts with zoom, pan, multiple timeframes
- **Call overlay on charts**: Core value prop - event markers showing when calls were made, overlaid on price action at exact timestamps
- **Influencer profiles**: Basic profile with bio, platforms, recent calls - similar to TipRanks analyst profiles
- **Call timeline/history**: Chronological list of all calls per influencer with asset, date, direction, price at call
- **Content source links**: Link back to original YouTube video or Twitter post for verification - builds trust
- **Basic filtering**: Filter by asset (BTC, ETH, etc.), influencer, timeframe, call direction
- **User authentication (invite-only)**: Requirement per project context - email/password with invite codes
- **Mobile responsiveness**: Charts and overlays must work on mobile - TradingView sets the standard

**Should have (competitive advantage):**
- **Multi-source call extraction**: Automatically find calls from YouTube + Twitter - this is the key technical challenge
- **Interactive chart with call overlays**: Visual correlation between call timing and price action - THE core differentiator
- **Influencer-first navigation**: Browse by influencer rather than asset - different mental model than most trading platforms
- **Call context snippets**: Show quote/clip from content where call was made - helps users understand reasoning
- **Timestamp precision**: Show exact timestamp when call was made - important for crypto where prices move fast
- **Admin-curated influencers**: Quality control - only track credible influencers, prevents spam/garbage

**Defer (v2+):**
- **User-submitted influencers**: Quality control nightmare, moderation overhead, legal liability - gate behind paid tier after platform proven
- **Comprehensive accuracy scoring**: Complex to calculate fairly (holding periods, cherry-picking, survivorship bias), legal risk - needs mature dataset
- **Additional content sources** (Telegram, Discord, podcasts): Diminishing returns, integration complexity - YouTube + Twitter sufficient
- **Auto-trading/signal copying**: Massive legal/regulatory liability - this is a research tool, not a trading bot
- **Social features** (comments, likes): Turns into social network, moderation nightmare - keep read-only

**Key insight from research:**
Admin curation is a feature, not a limitation. In a space full of spam and pump-and-dump influencers, a curated list of 5-10 credible influencers builds more trust than 100+ unvetted accounts.

### Architecture Approach

Standard full-stack separation with Rails API backend, Next.js frontend, background job pipeline for content processing, and adapter pattern for external API integrations. The architecture follows a layered approach: presentation (Next.js) → API gateway (Rails controllers) → application services → data integration adapters → background processing → storage.

**Major components:**

1. **Content Ingestion Service** — Pulls videos/tweets from influencers, queues processing jobs. Uses YouTube Data API v3 and Twitter API v2. Scheduled hourly via cron. Critical: implements quota tracking and rate limit handling.

2. **Call Extraction Pipeline** — Multi-stage background job chain: (1) audio extraction via yt-dlp, (2) transcription via Whisper API, (3) NLP extraction via GPT-4o, (4) validation (ticker symbols, confidence scoring, negation detection). Each stage runs independently with retry logic.

3. **Price Aggregator Service** — Fetches historical/real-time price data using modular adapter pattern. Supports multiple providers (CoinGecko, Binance, CoinMarketCap) with standardized interface. Implements tiered caching: 1-min for recent crypto, 1-hour for older data, 1-day for historical.

4. **Chart Builder Service** — Combines price data with call markers, formats for TradingView Lightweight Charts. Implements data downsampling (daily candles for >90 days, hourly for 7-90 days, 15-min for <7 days) to prevent performance collapse.

5. **Adapter Layer** — Isolates external API dependencies (YouTube, Twitter, price providers). Standardized interface enables swapping providers without changing business logic. Handles rate limiting, retries, response normalization.

6. **Background Job Infrastructure** — ActiveJob + Solid Queue (Rails 8 default, DB-based) or Sidekiq (Redis-based, more mature). Processes expensive operations asynchronously: content ingestion, transcription, call extraction, price fetching.

**Key architectural patterns from research:**
- Modular adapter pattern for price sources - easy to add/swap providers, system remains loosely coupled
- Background job pipeline for content processing - horizontal scalability, fault tolerance, automatic retries
- Event-driven call detection - when call extracted, multiple subscribers react (price fetcher, analytics) without tight coupling
- Backend-for-Frontend (optional) - Next.js API routes can aggregate multiple Rails endpoints, but not required for MVP

**Data flow (primary path):**
Cron scheduler → HourlyYoutubeSyncJob → ProcessYoutubeChannelJob (fetch videos) → ProcessVideoJob (download audio, transcribe) → ExtractCallsJob (NLP extraction) → Create Call records → FetchPriceDataJob (get historical prices). Fully asynchronous, each stage retryable independently.

### Critical Pitfalls

Research identified 8 critical pitfalls with prevention strategies. Top 5 for roadmap planning:

1. **YouTube API Quota Exhaustion Without Warning** — Platform silently stops ingesting content after hitting 10K units/day. With 5-10 influencers, quota burns faster than expected (caption fetching = 200 units each). **Avoid:** Implement quota tracking dashboard with alerts at 80%, use incremental fetching (publishedAfter parameter), cache metadata aggressively, request quota extension early (3-4 day approval).

2. **False Positive Call Extraction at 40-60%** — NLP extracts "calls" that aren't recommendations: "I'm NOT buying Bitcoin" flagged as BUY, "People are talking about NVDA" becomes recommendation. **Avoid:** Multi-stage pipeline with negation detection ("not", "don't", "won't" before action words), confidence scoring (only show >70% by default), context windows (analyze 2-3 sentences around keyword), include original quote snippet for verification.

3. **YouTube Auto-Caption Accuracy Below 62%** — Auto-generated captions mangle financial terms ("Bitcoin" → "big coin", "ETH" → "F", "NVDA" → "Nvidia"). Some videos lack captions entirely. **Avoid:** Fetch BOTH auto-captions AND manual captions if available, flag auto-caption extractions as "unverified", build financial terminology correction layer, show source transcript snippet to users.

4. **X/Twitter Rate Limits Without Token Rotation** — Strict 15-minute windows, 180 requests per token. Causes partial data updates, inconsistent state. **Avoid:** Monitor x-rate-limit-remaining header on EVERY response, implement exponential backoff on 429 errors, use token rotation (2-4 tokens = 2-4x capacity), design batch jobs to pause/resume across multiple windows.

5. **Timestamp Synchronization Nightmares** — Multiple timezone sources (YouTube = ISO 8601 with TZ, Twitter = UTC, Rails = server local, price APIs = exchange-specific). DST changes add chaos. Off-by-hours errors break performance tracking. **Avoid:** Store ALL timestamps in UTC in database, convert to UTC immediately on API ingestion, use timezone-aware libraries (Rails ActiveSupport::TimeZone), test around DST transitions.

**Additional critical pitfalls:**
- Ticker symbol disambiguation failures (common words as tickers: AI, GO, BIG)
- Stale price data from caching gone wrong (TTL too long, no freshness indicators)
- Chart rendering performance collapse with >1000 data points (DOM elements explode)

## Implications for Roadmap

Based on research, suggested phase structure follows dependency order: foundation → content pipeline → call extraction → price integration → visualization. This sequencing avoids architectural pitfalls (building features before infrastructure exists) and aligns with risk mitigation (tackle hard problems early when team has energy).

### Phase 1: Foundation & Core Data Model
**Rationale:** Everything depends on database schema and basic API. Can't ingest content without place to store it. Can't build charts without data to display. This phase establishes architectural foundation.

**Delivers:**
- PostgreSQL schema (influencers, calls, price_snapshots, content_sources)
- Rails API endpoints (CRUD for entities)
- Basic Next.js pages (influencer list, detail pages)
- User authentication (invite-only with Rails 8 built-in auth)
- Deployment infrastructure (Railway for Rails + PostgreSQL, Vercel for Next.js)

**Addresses features:**
- User authentication (invite-only) - table stakes
- Influencer profiles - table stakes
- Basic filtering - table stakes foundation

**Avoids pitfalls:**
- Timestamp synchronization - enforce UTC storage from day one
- Sets up monitoring infrastructure early (quota tracking placeholders)

**Research flags:** Standard CRUD patterns, well-documented. No additional research needed.

### Phase 2: Content Ingestion Pipeline (YouTube)
**Rationale:** Must have content before extracting calls. YouTube is easier than Twitter (more stable API, better documentation). Establishes background job patterns for rest of system.

**Delivers:**
- YouTube adapter + ingestor service
- Background job infrastructure (Solid Queue or Sidekiq)
- Scheduled jobs for hourly sync (ProcessYoutubeChannelJob)
- Quota monitoring dashboard with 80% alerts
- Admin interface to add/manage influencers and YouTube channels

**Uses stack:**
- YouTube Data API v3 integration
- ActiveJob for background processing
- Redis for job queue (if using Sidekiq) or Solid Queue (DB-based)

**Implements architecture:**
- Content Ingestion Service
- Adapter pattern for YouTube API
- Background job pipeline (first stage)

**Avoids pitfalls:**
- YouTube quota exhaustion - quota tracking dashboard, incremental fetching
- Rate limit handling patterns established for Twitter integration later

**Research flags:**
- **Needs research:** YouTube API quota optimization strategies (publishedAfter, batch requests)
- **Standard patterns:** Background job processing (ActiveJob well-documented)

### Phase 3: Call Extraction & NLP Pipeline
**Rationale:** Core technical challenge. Builds on Phase 2's content. This is what differentiates the platform from simple social media aggregators. Tackle hard problem early.

**Delivers:**
- Transcription service (Whisper API or yt-dlp + local Whisper)
- NLP extractor service (GPT-4o integration with structured outputs)
- Call validation service (negation detection, confidence scoring, ticker validation)
- Multi-stage job chain: transcribe → extract → validate → store
- Admin review interface for low-confidence extractions

**Uses stack:**
- OpenAI Whisper API for transcription
- GPT-4o for call extraction with JSON mode
- zod for schema validation

**Implements architecture:**
- Call Extraction Pipeline (all 3 stages)
- Event-driven pattern (CallDetectedEvent triggers downstream actions)

**Avoids pitfalls:**
- False positive call extraction - multi-stage validation with confidence thresholds
- YouTube auto-caption accuracy - prefer manual captions, flag auto-captions as "unverified"
- Ticker symbol disambiguation - validate against known symbols, require context
- Caption extraction failures - graceful handling of missing captions

**Research flags:**
- **Needs research:** NLP prompt engineering for financial call extraction (domain-specific)
- **Needs research:** Confidence scoring calibration and threshold tuning
- **Needs research:** Financial terminology correction dictionary for common misheard terms

### Phase 4: Price Data Integration
**Rationale:** Need price data to overlay calls on charts. Can develop in parallel with Phase 3 since no hard dependency. Establishes adapter pattern for future provider additions.

**Delivers:**
- Price adapter pattern implementation (BasePriceAdapter interface)
- CoinGecko adapter with rate limit handling
- Price fetcher service with tiered caching (1-min crypto, 1-hour historical)
- Historical price backfill for existing calls
- Cache freshness monitoring and stale data detection

**Uses stack:**
- CoinGecko Free API (30 calls/min, 10K/month)
- Redis for caching (if using Sidekiq) or DB caching
- HTTParty or Faraday for HTTP client

**Implements architecture:**
- Price Aggregator Service
- Modular adapter pattern (enables swapping to Binance, CoinMarketCap later)
- Tiered caching strategy

**Avoids pitfalls:**
- Stale price data - cache TTL ≤5 minutes, freshness indicators in UI
- API rate limits - respect 30 calls/min, implement backoff

**Research flags:**
- **Standard patterns:** Price API integration well-documented
- **Skip research:** CoinGecko API is straightforward, official docs sufficient

### Phase 5: Chart Rendering & Call Overlay
**Rationale:** Final user-facing feature. Depends on Phase 3 (calls) and Phase 4 (prices). This is the "aha moment" - where users see the core value prop.

**Delivers:**
- TradingView Lightweight Charts integration
- Chart builder service (combines prices + calls, formats for TradingView)
- Call overlay rendering (event markers at timestamps)
- Chart controls (timeframe selectors, zoom, pan)
- Data downsampling (daily for >90 days, hourly for 7-90 days, 15-min for <7 days)
- Call timeline/history view per influencer

**Uses stack:**
- TradingView Lightweight Charts 5.1.0
- TanStack React Query for chart data fetching
- Next.js server components for optimal performance

**Implements architecture:**
- Chart Builder Service
- Overlay formatting for TradingView
- Progressive loading (load recent 30 days by default, more on zoom-out)

**Avoids pitfalls:**
- Chart rendering performance collapse - data downsampling, limit to 30-90 days default
- Lazy loading (only render charts when scrolled into view)

**Addresses features:**
- Price chart visualization - table stakes
- Call overlay on charts - core differentiator
- Call timeline/history - table stakes
- Content source links - table stakes
- Influencer-first navigation - competitive advantage
- Timestamp precision - competitive advantage

**Research flags:**
- **Needs research:** TradingView datafeed interface implementation (specific API contract)
- **Standard patterns:** React charting libraries well-documented

### Phase 6: Twitter/X Integration (Optional V1.x)
**Rationale:** Defer until YouTube pipeline proven. Twitter is more complex (stricter rate limits, $100/month minimum for Basic tier). Add after core value validated.

**Delivers:**
- Twitter adapter + ingestor service
- Tweet processing pipeline (simpler than YouTube - no transcription)
- Token rotation pool (2-4 OAuth tokens for 2-4x capacity)
- Rate limit monitoring dashboard

**Avoids pitfalls:**
- X rate limits without token rotation - implement from day one with Twitter
- Monitor x-rate-limit-remaining header on every response

**Research flags:**
- **Needs research:** X API v2 rate limit optimization, webhook subscription for real-time

### Phase Ordering Rationale

**Why this order:**
1. **Foundation first** (Phase 1) - architectural foundation, can't build anything without it
2. **Content before extraction** (Phase 2 → 3) - need content to extract calls from, logical dependency
3. **Prices in parallel with extraction** (Phase 3 || 4) - no hard dependency, can develop simultaneously
4. **Charts last** (Phase 5) - requires both calls and prices, this is where everything comes together
5. **Twitter deferred** (Phase 6) - prove core concept with YouTube first, avoid complexity

**Why this grouping:**
- Phase 1 = Infrastructure (pure technical foundation)
- Phase 2-3 = Content pipeline (ingestion → extraction, tightly coupled)
- Phase 4 = Price data (can parallelize with Phase 3)
- Phase 5 = Visualization (integrates everything)
- Phase 6 = Expansion (add second source after validation)

**How this avoids pitfalls:**
- Quota monitoring built in Phase 2 (before quota becomes problem)
- False positive mitigation built in Phase 3 (validation from start, not retrofitted)
- Timestamp normalization enforced in Phase 1 (prevent corruption from beginning)
- Performance optimization built in Phase 5 (downsampling from start, not after collapse)
- Twitter rate limits handled properly in Phase 6 (learn from YouTube in Phase 2)

### Research Flags

**Phases needing deeper research during planning:**

- **Phase 2 (YouTube):** YouTube API quota optimization - need to research publishedAfter parameter usage, batch request strategies, quota extension process
- **Phase 3 (NLP):** Prompt engineering for financial call extraction - domain-specific, need to research effective prompts for GPT-4o structured outputs, confidence calibration
- **Phase 3 (NLP):** Financial terminology correction - need to compile dictionary of commonly misheard terms from auto-captions
- **Phase 5 (Charts):** TradingView datafeed interface - specific API contract for Lightweight Charts, need to research exact implementation
- **Phase 6 (Twitter):** X API v2 optimization - research webhook subscription for real-time, token rotation architecture

**Phases with standard patterns (skip research-phase):**

- **Phase 1 (Foundation):** Rails CRUD, PostgreSQL schema, Next.js pages - extremely well-documented, no additional research needed
- **Phase 4 (Price):** CoinGecko API integration - official docs sufficient, straightforward REST API
- **Phase 2 (Jobs):** ActiveJob background processing - Rails standard, comprehensive guides available

**Research confidence by phase:**

| Phase | Confidence | Reason |
|-------|------------|--------|
| Phase 1 | HIGH | Standard Rails/Next.js patterns, official docs |
| Phase 2 | MEDIUM | YouTube API well-documented, but quota optimization needs testing |
| Phase 3 | MEDIUM | NLP extraction is domain-specific, prompts need tuning |
| Phase 4 | HIGH | Price APIs straightforward, CoinGecko docs excellent |
| Phase 5 | MEDIUM | TradingView library well-documented, but datafeed needs research |
| Phase 6 | MEDIUM | Twitter API documented, but rate limits complex in practice |

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All versions verified via official sources and recent web search (Feb 2026). Rails 8.1.2, Next.js 16, PostgreSQL 16, Ruby 3.4 all confirmed as latest stable. Integration patterns well-established. |
| Features | MEDIUM | Based on web search of comparable platforms (TipRanks, LunarCrush, TradingView, crypto tracking tools). No direct competitors found matching this exact concept, which suggests market gap. Feature expectations inferred from related domains. |
| Architecture | HIGH | Standard full-stack patterns (Rails API + Next.js frontend) extensively documented. Background job pipeline, adapter pattern, BFF layer all battle-tested. Data flow based on similar social media monitoring and financial data platforms. |
| Pitfalls | MEDIUM-HIGH | YouTube quota limits, Twitter rate limits, caption accuracy, timestamp issues all well-documented through official API docs and practitioner blogs. NLP false positives based on general financial NLP research, not domain-specific to this use case. Chart performance issues confirmed through TradingView community. |

**Overall confidence:** HIGH

The technical stack and architecture are well-established patterns with strong documentation. The main uncertainty is in feature prioritization (no exact competitor to benchmark) and NLP extraction tuning (domain-specific). However, the core technical approach is sound and risks are well-understood with clear mitigation strategies.

### Gaps to Address

**Gaps identified during research:**

1. **NLP prompt tuning for call extraction:** Research provides general guidance on financial NLP, but exact prompt engineering for GPT-4o to extract calls from influencer content will require experimentation. **Handle:** Plan for prompt iteration in Phase 3, allocate time for tuning confidence thresholds based on real data.

2. **YouTube API quota in practice:** Research shows 10K units/day default, but actual consumption rate depends on usage patterns (video metadata vs. caption fetching). **Handle:** Implement comprehensive quota tracking in Phase 2, request quota increase early, have degraded mode ready (prioritize high-engagement influencers).

3. **TradingView datafeed contract:** Research confirms Lightweight Charts is the right choice, but exact datafeed interface implementation needs hands-on coding. **Handle:** Prototype datafeed during Phase 5 kickoff, reference official examples, budget extra time for integration debugging.

4. **False positive calibration:** Research indicates 40-60% false positive rate for basic NLP, but actual rate depends on prompt quality and validation logic. **Handle:** Build admin review interface in Phase 3, collect ground truth data, iterate on confidence thresholds.

5. **Influencer engagement patterns:** Research doesn't specify how frequently crypto influencers post or typical video length (impacts quota/transcription costs). **Handle:** Monitor actual usage during Phase 2-3, adjust batch frequency if needed, consider sampling (process every other video) if costs spike.

6. **Chart performance with real data:** Research shows >1000 data points causes issues, but actual threshold depends on device/browser. **Handle:** Implement data downsampling from start in Phase 5, add performance monitoring, tune thresholds based on user reports.

## Sources

### Primary (HIGH confidence)

**Stack & Official Documentation:**
- Rails 8.1.2 Release: https://rubyonrails.org/2026/1/22/rails-version-8-1-2-has-been-released
- Rails 8.0 Release Notes: https://guides.rubyonrails.org/8_0_release_notes.html
- Next.js 16 Release: https://nextjs.org/blog/next-15 (search found 16.1.2 on npm)
- PostgreSQL Versioning Policy: https://www.postgresql.org/support/versioning/
- Ruby & Rails Compatibility: https://www.fastruby.io/blog/ruby/rails/versions/compatibility-table.html
- TradingView Lightweight Charts: https://www.tradingview.com/lightweight-charts/
- OpenAI Whisper API: https://platform.openai.com/docs/guides/speech-to-text
- CoinGecko API: https://www.coingecko.com/en/api

**API Documentation:**
- YouTube API Quota Guide: https://developers.google.com/youtube/v3/guides/quota_and_compliance_audits
- YouTube API Quota Calculator: https://developers.google.com/youtube/v3/determine_quota_cost
- X API Rate Limits: https://docs.x.com/x-api/fundamentals/rate-limits

### Secondary (MEDIUM confidence)

**Architecture & Patterns:**
- Railway Rails Deployment: https://docs.railway.com/guides/rails
- TanStack Query with Next.js: https://tanstack.com/query/latest/docs/framework/react/examples/nextjs
- Active Job Basics: https://guides.rubyonrails.org/active_job_basics.html
- Social Media Feed System Design: https://javatechonline.com/social-media-feed-system-design/
- Real-Time Data Pipelines: https://www.landskill.com/blog/real-time-data-pipelines-patterns/

**Feature Benchmarks:**
- TipRanks Review (analyst tracking): https://tickernerd.com/resources/tipranks-review/
- LunarCrush (crypto social tracking): https://lunarcrush.com/
- Crypto Influencer Marketing Guide 2026: https://ninjapromo.io/crypto-influencer-marketing

**Pitfalls & Best Practices:**
- YouTube API Limits 2025: https://getlate.dev/blog/youtube-api-limits-how-to-calculate-api-usage-cost-and-fix-exceeded-api-quota
- YouTube Auto Caption Accuracy Study: https://www.consumerreports.org/disability-rights/auto-captions-often-fall-short-on-zoom-facebook-and-others-a9742392879/
- NLP False Positives in Finance: https://www.johnsnowlabs.com/examining-the-impact-of-nlp-in-financial-services/
- Timezone Best Practices for Databases: https://www.tinybird.co/blog/database-timestamps-timezones
- TradingView Performance Optimization: https://pineify.app/resources/blog/tradingview-running-slow-complete-guide-to-fix-lag-and-performance-issues

### Tertiary (LOW confidence, needs validation)

**NLP & Extraction:**
- Financial NLP Accuracy Challenges: https://chatfin.ai/blog/nlp-in-finance-natural-language-processing-for-financial-analysis-guide/
- Stock Symbol Recognition in Tweets: https://www.researchgate.net/publication/261832650_Recognition_of_NASDAQ_stock_symbols_in_tweets

**Performance & Optimization:**
- Real-time vs Batch Data Tradeoffs: https://www.confluent.io/learn/batch-vs-real-time-data-processing/
- Crypto API Real-time Best Practices 2026: https://coinranking.com/blog/best-real-time-crypto-price-apis-in-2026-a-developer-guide/

---
*Research completed: 2026-02-05*
*Ready for roadmap: yes*
