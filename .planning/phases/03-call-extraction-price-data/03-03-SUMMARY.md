---
phase: 03-call-extraction-price-data
plan: 03
subsystem: api
tags: [httparty, coingecko, yahoo-finance, adapter-pattern, background-jobs, solid-queue]

# Dependency graph
requires:
  - phase: 03-call-extraction-price-data (03-01)
    provides: Asset and PriceSnapshot models with unique index on [asset_id, timestamp]
provides:
  - Price adapter pattern (BaseAdapter, CoingeckoAdapter, YahooFinanceAdapter)
  - PriceFetcher routing service (crypto -> CoinGecko, macro -> Yahoo Finance)
  - Background jobs for scheduled price fetching (FetchPriceDataJob, FetchAllPricesJob)
  - Recurring schedule for daily price updates
affects: [04-chart-rendering, production-deployment]

# Tech tracking
tech-stack:
  added: []
  patterns: [adapter-pattern-for-swappable-providers, bulk-upsert-for-deduplication, staggered-job-enqueueing]

key-files:
  created:
    - api/app/services/prices/base_adapter.rb
    - api/app/services/prices/coingecko_adapter.rb
    - api/app/services/prices/yahoo_finance_adapter.rb
    - api/app/services/prices/price_fetcher.rb
    - api/app/jobs/fetch_price_data_job.rb
    - api/app/jobs/fetch_all_prices_job.rb
  modified:
    - api/config/recurring.yml

key-decisions:
  - "Removed Faraday::Error from retry_on since project uses HTTParty not Faraday"
  - "OHLC endpoint chosen over market_chart for CoinGecko (provides open/high/low/close vs just close)"
  - "Staggered 2s delays between job enqueues to respect CoinGecko 30 calls/min rate limit"

patterns-established:
  - "Adapter pattern: BaseAdapter defines interface, concrete adapters implement per-provider"
  - "Bulk upsert: PriceSnapshot.upsert_all with unique_by for idempotent data ingestion"
  - "Smart fetch: 365 days for initial load, 7 days for incremental updates"

# Metrics
duration: 2min
completed: 2026-02-06
---

# Phase 3 Plan 3: Price Data Pipeline Summary

**Modular price adapter services (CoinGecko OHLC for crypto, Yahoo Finance v8/chart for macro) with PriceFetcher routing and daily scheduled background jobs**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-05T19:18:02Z
- **Completed:** 2026-02-05T19:20:07Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Adapter pattern for swappable price providers (changing ADAPTERS hash swaps providers without code changes)
- CoinGecko OHLC integration with API key auth, rate limit handling, and error recovery
- Yahoo Finance v8/chart integration with User-Agent header and graceful error handling
- Bulk upsert via PriceSnapshot.upsert_all prevents duplicate price data
- Background jobs with staggered enqueueing respecting CoinGecko rate limits
- Recurring schedule: daily at 6am (production), hourly (development)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create price adapter services** - `3633a49` (feat)
2. **Task 2: Create price fetch background jobs and recurring schedule** - `fe10df0` (feat)

## Files Created/Modified
- `api/app/services/prices/base_adapter.rb` - Abstract adapter interface with save_snapshots bulk upsert
- `api/app/services/prices/coingecko_adapter.rb` - CoinGecko OHLC endpoint for crypto prices
- `api/app/services/prices/yahoo_finance_adapter.rb` - Yahoo Finance v8/chart for macro prices
- `api/app/services/prices/price_fetcher.rb` - Adapter selector routing by asset_class
- `api/app/jobs/fetch_price_data_job.rb` - Per-asset price fetch job with retry on network errors
- `api/app/jobs/fetch_all_prices_job.rb` - Batch dispatcher with staggered delays for rate limiting
- `api/config/recurring.yml` - Added fetch_all_prices to production and development schedules

## Decisions Made
- **Removed Faraday::Error from retry_on** - Project uses HTTParty, not Faraday. Including Faraday::Error would cause NameError at runtime.
- **OHLC endpoint for CoinGecko** - `/coins/{id}/ohlc` provides open/high/low/close data needed for chart rendering, vs market_chart which only returns close prices.
- **Staggered 2-second delays** - CoinGecko free tier allows 30 calls/min; 2s between enqueues keeps us well within limits.
- **Smart fetch days** - 365 days for initial load (first time asset has no snapshots), 7 days for incremental updates (daily new candles only).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed Faraday::Error from FetchPriceDataJob retry_on**
- **Found during:** Task 2 (FetchPriceDataJob creation)
- **Issue:** Plan specified `retry_on Faraday::Error` but Faraday gem is not in the Gemfile; would cause NameError
- **Fix:** Removed Faraday::Error, kept HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout
- **Files modified:** api/app/jobs/fetch_price_data_job.rb
- **Verification:** Syntax check passes, Rails runner loads class without error
- **Committed in:** fe10df0 (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Essential fix to prevent runtime NameError. No scope creep.

## Issues Encountered
None.

## User Setup Required

**CoinGecko API key required for crypto price data:**
- Sign up at https://www.coingecko.com/en/api/pricing (Demo plan is free)
- Get API key from Developer Dashboard
- Set `COINGECKO_API_KEY` environment variable in production

## Next Phase Readiness
- Price adapters ready for Phase 4 chart rendering
- COINGECKO_API_KEY must be set in production for crypto price data to flow
- Yahoo Finance requires no API key (public endpoint with User-Agent header)

---
*Phase: 03-call-extraction-price-data*
*Completed: 2026-02-06*
