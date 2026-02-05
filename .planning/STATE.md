# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-05)

**Core value:** Users can visually see when an influencer made a call and what the price did after
**Current focus:** Phase 2 - Influencer & Content Pipeline

## Current Position

Phase: 2 of 4 (Influencer & Content Pipeline)
Plan: 4 of 5 complete (02-01, 02-02, 02-03, 02-04 done; 02-05 remaining)
Status: In progress
Last activity: 2026-02-05 - Completed 02-02-PLAN.md (Influencer Frontend Pages)

Progress: [██████░░░░] 60%

## Production URLs

| Service | URL |
|---------|-----|
| API | https://api-production-b1ab.up.railway.app |
| Frontend | https://frontend-production-9ba4.up.railway.app |

## Performance Metrics

**Velocity:**
- Total plans completed: 7
- Average duration: ~11 min
- Total execution time: ~74 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 3 | ~60 min | ~20 min |
| 2 | 4 | ~14 min | ~3.5 min |

**Recent Trend:**
- Last 5 plans: 01-03 (45m), 02-01 (5m), 02-03 (2m), 02-04 (2m), 02-02 (5m)
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

### Pending Todos

None yet.

### Blockers/Concerns

**Research-flagged areas for Phase 2:**
- YouTube API quota optimization needs testing (10K units/day with 5-10 influencers)
- Batch processing frequency (research suggests 15-30 min, requirements specify hourly)
- **NEW:** YOUTUBE_API_KEY must be set in production for YouTube sync to work
- **NEW:** TWITTER_API_KEY must be set in production for Twitter sync to work

**Research-flagged areas for Phase 3:**
- NLP prompt engineering for financial call extraction (domain-specific tuning needed)
- False positive rate mitigation (research indicates 40-60% without validation)
- Confidence score calibration (threshold tuning required)

**Research-flagged areas for Phase 4:**
- TradingView Lightweight Charts datafeed interface (specific API contract)
- Chart performance with >1000 data points (downsampling strategy required)

## Session Continuity

Last session: 2026-02-05
Stopped at: Completed 02-02-PLAN.md
Resume file: None

---
*Created: 2026-02-05*
*Last updated: 2026-02-05*
