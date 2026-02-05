# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-05)

**Core value:** Users can visually see when an influencer made a call and what the price did after
**Current focus:** Phase 2 Complete - Ready for Phase 3 (Call Extraction)

## Current Position

Phase: 2 of 4 (Influencer & Content Pipeline) - COMPLETE
Plan: 5 of 5 complete (02-01, 02-02, 02-03, 02-04, 02-05 done)
Status: Phase 2 complete, ready for Phase 3
Last activity: 2026-02-06 - Completed 02-05-PLAN.md (Content History Frontend)

Progress: [████████░░] 80%

## Production URLs

| Service | URL |
|---------|-----|
| API | https://api-production-b1ab.up.railway.app |
| Frontend | https://frontend-production-9ba4.up.railway.app |

## Performance Metrics

**Velocity:**
- Total plans completed: 8
- Average duration: ~10 min
- Total execution time: ~78 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 3 | ~60 min | ~20 min |
| 2 | 5 | ~18 min | ~3.6 min |

**Recent Trend:**
- Last 5 plans: 02-01 (5m), 02-03 (2m), 02-04 (2m), 02-02 (5m), 02-05 (4m)
- Trend: Frontend and data model plans execute quickly

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

### Pending Todos

None yet.

### Blockers/Concerns

**Phase 2 Production Requirements:**
- YOUTUBE_API_KEY must be set in production for YouTube sync to work
- TWITTER_API_KEY must be set in production for Twitter sync to work

**Research-flagged areas for Phase 3:**
- NLP prompt engineering for financial call extraction (domain-specific tuning needed)
- False positive rate mitigation (research indicates 40-60% without validation)
- Confidence score calibration (threshold tuning required)

**Research-flagged areas for Phase 4:**
- TradingView Lightweight Charts datafeed interface (specific API contract)
- Chart performance with >1000 data points (downsampling strategy required)

## Session Continuity

Last session: 2026-02-06
Stopped at: Completed 02-05-PLAN.md (Phase 2 complete)
Resume file: None

---
*Created: 2026-02-05*
*Last updated: 2026-02-06*
