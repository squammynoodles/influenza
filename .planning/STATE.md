# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-05)

**Core value:** Users can visually see when an influencer made a call and what the price did after
**Current focus:** Phase 3 Complete - Ready for Phase 4 (Chart Visualization)

## Current Position

Phase: 3 of 4 complete (Call Extraction & Price Data)
Plan: 4 of 4 complete (03-01, 03-02, 03-03, 03-04 done)
Status: Phase 3 verified and complete
Last activity: 2026-02-06 - Phase 3 verified (21/21 must-haves passed)

Progress: [████████████████] 100% (12/12 plans across 3 phases)

## Production URLs

| Service | URL |
|---------|-----|
| API | https://api-production-b1ab.up.railway.app |
| Frontend | https://frontend-production-9ba4.up.railway.app |

## Performance Metrics

**Velocity:**
- Total plans completed: 12
- Average duration: ~7 min
- Total execution time: ~86 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 3 | ~60 min | ~20 min |
| 2 | 5 | ~18 min | ~3.6 min |
| 3 | 4 | ~8 min | ~2 min |

**Recent Trend:**
- Last 5 plans: 02-05 (4m), 03-01 (2m), 03-02 (2m), 03-03 (2m), 03-04 (2m)
- Trend: API controller plans execute very quickly with established patterns

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- **Railway for deployment** - Simple PaaS, auto-detects Dockerfile and Next.js
- **No Redis needed** - Rails 8 Solid Queue uses PostgreSQL for background jobs
- **Public DATABASE_URL** - Railway internal DNS had issues, using public endpoint
- **Monorepo watch paths** - Configure in Railway to avoid rebuilding both services
- **STI for Content types** - YoutubeVideo and Tweet share most attributes, using single table inheritance
- **Avatar as URL** - Store avatar_url string instead of ActiveStorage, avatars hosted externally
- **Innertube for transcripts** - Scrape YouTube pages for captions (0 API quota vs paid API)
- **HTTParty for HTTP requests** - Added for transcript fetching, simpler than Net::HTTP
- **TwitterAPI.io for tweets** - Third-party API ($1 free credit), official Twitter API is $200+/month
- **Filter retweets** - Only store original tweets for call extraction, not reposted content
- **Staggered scheduling** - YouTube at :00, Twitter at :30 for easier debugging
- **Dashboard route group** - All authenticated pages under (dashboard) for shared layout
- **Server Actions for forms** - useActionState with Zod validation for all CRUD operations
- **URL-based content filtering** - Shareable/bookmarkable filter states via searchParams
- **Decimal(20,8) for prices** - Handles crypto micro-prices and large macro values
- **Confidence as decimal(5,4)** - 0.0000-1.0000 range with 4 decimal precision
- **extraction_status defaults pending** - All existing/new content auto-queued for extraction
- **GPT-4o-mini for extraction** - Cost-effective at $0.15/1M input tokens, sufficient for call extraction
- **Confidence >= 0.7 threshold** - Only persist high-confidence calls; 0.5-0.7 marked low_confidence
- **Extraction at :15 past hour** - Staggered after YouTube (:00) and Twitter (:30) ingestion
- **Adapter pattern for price providers** - BaseAdapter interface with CoingeckoAdapter/YahooFinanceAdapter, swappable via ADAPTERS hash
- **Staggered price job enqueueing** - 2s delays between CoinGecko API calls to respect 30 calls/min rate limit
- **OHLC endpoint for CoinGecko** - /coins/{id}/ohlc provides full OHLC data needed for chart rendering
- **Flat + nested API routes** - Both /api/v1/calls?influencer_id=X and /api/v1/influencers/:id/calls for flexibility
- **No pagination for small datasets** - Assets (fixed ~15) and price_snapshots (bounded by date range) skip pagination

### Pending Todos

None yet.

### Blockers/Concerns

**Phase 2-3 Production Requirements:**
- YOUTUBE_API_KEY must be set in production for YouTube sync to work
- TWITTER_API_KEY must be set in production for Twitter sync to work
- OPENAI_API_KEY must be set in production for call extraction to work
- COINGECKO_API_KEY must be set in production for crypto price data to work

**Research-flagged areas for Phase 4:**
- TradingView Lightweight Charts datafeed interface (specific API contract)
- Chart performance with >1000 data points (downsampling strategy required)

## Session Continuity

Last session: 2026-02-06
Stopped at: Phase 3 verified and complete - ready for Phase 4
Resume file: None

---
*Created: 2026-02-05*
*Last updated: 2026-02-06*
