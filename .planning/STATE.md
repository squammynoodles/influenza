# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-05)

**Core value:** Users can visually see when an influencer made a call and what the price did after
**Current focus:** Phase 3 In Progress - Call Extraction & Price Data

## Current Position

Phase: 3 of 4 (Call Extraction & Price Data)
Plan: 2 of 4 complete (03-01, 03-02 done)
Status: In progress
Last activity: 2026-02-06 - Completed 03-02-PLAN.md (Call Extraction Pipeline)

Progress: [████████░░] 83% (10/12 plans)

## Production URLs

| Service | URL |
|---------|-----|
| API | https://api-production-b1ab.up.railway.app |
| Frontend | https://frontend-production-9ba4.up.railway.app |

## Performance Metrics

**Velocity:**
- Total plans completed: 10
- Average duration: ~8 min
- Total execution time: ~82 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 3 | ~60 min | ~20 min |
| 2 | 5 | ~18 min | ~3.6 min |
| 3 | 2 | ~4 min | ~2 min |

**Recent Trend:**
- Last 5 plans: 02-04 (2m), 02-02 (5m), 02-05 (4m), 03-01 (2m), 03-02 (2m)
- Trend: Service and job plans execute quickly when models are already in place

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

### Pending Todos

None yet.

### Blockers/Concerns

**Phase 2-3 Production Requirements:**
- YOUTUBE_API_KEY must be set in production for YouTube sync to work
- TWITTER_API_KEY must be set in production for Twitter sync to work
- OPENAI_API_KEY must be set in production for call extraction to work

**Research-flagged areas for Phase 4:**
- TradingView Lightweight Charts datafeed interface (specific API contract)
- Chart performance with >1000 data points (downsampling strategy required)

## Session Continuity

Last session: 2026-02-06
Stopped at: Completed 03-02-PLAN.md (Call Extraction Pipeline)
Resume file: None

---
*Created: 2026-02-05*
*Last updated: 2026-02-06*
