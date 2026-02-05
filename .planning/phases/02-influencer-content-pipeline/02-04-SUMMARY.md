---
phase: 02-influencer-content-pipeline
plan: 04
subsystem: api, ingestion
tags: [twitter, twitterapi.io, httparty, solid-queue, background-jobs]

# Dependency graph
requires:
  - phase: 02-01
    provides: TwitterAccount and Tweet models, Content STI
provides:
  - Twitter::TweetFetcher service for TwitterAPI.io integration
  - Twitter::AccountSyncService for orchestrating tweet ingestion
  - SyncTwitterAccountsJob and SyncSingleTwitterAccountJob for scheduled processing
  - Hourly Twitter sync schedule at :30 (staggered from YouTube at :00)
affects: [02-05, 03-call-extraction]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Per-account job spawning for parallel processing"
    - "Retry with polynomially_longer backoff for rate limits"
    - "Staggered scheduling (YouTube :00, Twitter :30)"

key-files:
  created:
    - api/app/services/twitter/tweet_fetcher.rb
    - api/app/services/twitter/account_sync_service.rb
    - api/app/jobs/sync_twitter_accounts_job.rb
    - api/app/jobs/sync_single_twitter_account_job.rb
  modified:
    - api/config/recurring.yml

key-decisions:
  - "Filter out retweets to focus on original content for call extraction"
  - "Stagger Twitter sync at :30, YouTube at :00 for easier debugging"

patterns-established:
  - "Twitter service classes in app/services/twitter/"
  - "Master/worker job pattern for per-account processing"

# Metrics
duration: 2min
completed: 2026-02-05
---

# Phase 2 Plan 4: Twitter Ingestion Service Summary

**TwitterAPI.io integration with hourly background job sync, filtering retweets for original content only**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-05T17:56:09Z
- **Completed:** 2026-02-05T17:58:30Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- TwitterAPI.io integration via X-API-Key header authentication
- Tweet fetcher with rate limit handling (RateLimitError) and retry logic
- Account sync service that filters retweets and stores only original content
- Background jobs with exponential backoff retry for API errors
- Hourly schedule staggered from YouTube sync for easier debugging

## Task Commits

Each task was committed atomically:

1. **Task 1: Create TwitterAPI.io tweet fetcher service** - `48fdb45` (feat)
2. **Task 2: Create account sync service** - `d9592b1` (feat)
3. **Task 3: Create background jobs and update recurring schedule** - `9cf4730` (feat)

**Plan metadata:** (included in final commit)

## Files Created/Modified

- `api/app/services/twitter/tweet_fetcher.rb` - TwitterAPI.io integration, handles auth, rate limits, tweet parsing
- `api/app/services/twitter/account_sync_service.rb` - Orchestrates fetching and storing tweets, filters retweets
- `api/app/jobs/sync_twitter_accounts_job.rb` - Master job that spawns per-account jobs
- `api/app/jobs/sync_single_twitter_account_job.rb` - Per-account sync with retry logic
- `api/config/recurring.yml` - Updated with Twitter sync schedule at :30

## Decisions Made

- **Filter retweets:** AccountSyncService filters out retweets because we want original content for call extraction, not reposted content
- **Staggered scheduling:** Twitter runs at :30, YouTube at :00 to spread load and make debugging easier

## Deviations from Plan

None - plan executed exactly as written.

## User Setup Required

**External services require manual configuration.**

Environment variables needed:
- `TWITTER_API_KEY` - Get from https://twitterapi.io -> Sign up -> Dashboard -> API Keys ($1 free credit to start)

Verification command:
```ruby
# In Rails console with TWITTER_API_KEY set
fetcher = Twitter::TweetFetcher.new
tweets = fetcher.recent_tweets('elonmusk', since: 7.days.ago)
puts tweets.count
```

## Issues Encountered

None.

## Next Phase Readiness

- Twitter ingestion pipeline complete and ready for use
- Follows same patterns as YouTube ingestion (plan 02-03)
- Ready for Phase 3: Call extraction can process Tweet.body for financial calls
- Note: TWITTER_API_KEY environment variable required in production

---
*Phase: 02-influencer-content-pipeline*
*Completed: 2026-02-05*
