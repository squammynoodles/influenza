---
phase: 03-call-extraction-price-data
plan: 01
subsystem: database
tags: [rails, migrations, models, assets, calls, price-snapshots, seeds]

# Dependency graph
requires:
  - phase: 02-influencer-content-pipeline
    provides: "Content and Influencer models with associations"
provides:
  - "Asset model with symbol, name, asset_class, coingecko_id, yahoo_ticker"
  - "Call model with direction, confidence, quote, reasoning, called_at"
  - "PriceSnapshot model with OHLCV data (open, high, low, close, volume)"
  - "extraction_status and calls_extracted_at columns on Content"
  - "15 seeded assets (11 crypto, 4 macro) with provider ID mappings"
affects:
  - 03-02 (call extraction service needs Call and Asset models)
  - 03-03 (price fetching service needs PriceSnapshot and Asset models)
  - 03-04 (background jobs need extraction_status on Content)
  - 04-chart-dashboard (charts need PriceSnapshot and Call data)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "OHLCV price data schema (precision: 20, scale: 8 for crypto prices)"
    - "Idempotent seeds with find_or_create_by!"
    - "extraction_status tracking on Content (pending -> processing -> completed -> failed)"

key-files:
  created:
    - api/app/models/asset.rb
    - api/app/models/call.rb
    - api/app/models/price_snapshot.rb
    - api/db/migrate/20260205191129_create_assets.rb
    - api/db/migrate/20260205191134_create_calls.rb
    - api/db/migrate/20260205191139_create_price_snapshots.rb
    - api/db/migrate/20260205191144_add_extraction_status_to_contents.rb
  modified:
    - api/app/models/content.rb
    - api/app/models/influencer.rb
    - api/db/seeds.rb
    - api/db/schema.rb

key-decisions:
  - "Decimal precision 20 scale 8 for price data to handle crypto micro-prices"
  - "Confidence stored as decimal(5,4) for 0.0000-1.0000 range"
  - "Composite unique index on [asset_id, timestamp] for PriceSnapshot dedup"
  - "extraction_status defaults to pending for all existing and new content"

patterns-established:
  - "Asset provider mapping: coingecko_id for crypto, yahoo_ticker for macro"
  - "Call associations: belongs_to content, influencer, and asset (triple FK)"

# Metrics
duration: 2min
completed: 2026-02-06
---

# Phase 3 Plan 1: Data Models & Seeds Summary

**Asset, Call, PriceSnapshot tables with OHLCV schema, extraction tracking on Content, and 15 seeded assets (11 crypto + 4 macro) with CoinGecko/Yahoo provider mappings**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-05T19:11:19Z
- **Completed:** 2026-02-05T19:13:36Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments
- Created Asset, Call, and PriceSnapshot models with full validations, associations, and scopes
- Added extraction_status (default: "pending") and calls_extracted_at columns to Content
- Seeded 15 supported assets (11 crypto with coingecko_id, 4 macro with yahoo_ticker)
- All seeds are idempotent via find_or_create_by!

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Asset, Call, and PriceSnapshot migrations and models** - `bbd044d` (feat)
2. **Task 2: Seed supported assets** - `6aa2a4b` (feat)

## Files Created/Modified
- `api/app/models/asset.rb` - Asset model with crypto/macro scopes, symbol uniqueness validation
- `api/app/models/call.rb` - Call model with bullish/bearish/high_confidence scopes, triple belongs_to
- `api/app/models/price_snapshot.rb` - PriceSnapshot model with chronological/for_range scopes
- `api/app/models/content.rb` - Added has_many :calls association
- `api/app/models/influencer.rb` - Added has_many :calls association
- `api/db/migrate/20260205191129_create_assets.rb` - Assets table with unique symbol index
- `api/db/migrate/20260205191134_create_calls.rb` - Calls table with composite indexes on influencer+date, asset+date
- `api/db/migrate/20260205191139_create_price_snapshots.rb` - Price snapshots with unique [asset_id, timestamp] index
- `api/db/migrate/20260205191144_add_extraction_status_to_contents.rb` - Extraction tracking columns on contents
- `api/db/seeds.rb` - 15 supported assets with provider ID mappings
- `api/db/schema.rb` - Auto-generated schema reflecting all new tables

## Decisions Made
- Decimal precision 20, scale 8 for price columns to handle crypto micro-prices and large values
- Confidence as decimal(5,4) allowing 0.0000 to 1.0000 range with 4 decimal precision
- Composite unique index on [asset_id, timestamp] prevents duplicate price snapshots
- extraction_status defaults to "pending" so all existing content is queued for extraction

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Asset, Call, and PriceSnapshot models ready for call extraction service (03-02)
- Price fetching service (03-03) can use Asset.crypto/Asset.macro scopes with provider IDs
- Content.extraction_status ready for background job orchestration (03-04)
- All 15 assets seeded and available for immediate use

---
*Phase: 03-call-extraction-price-data*
*Completed: 2026-02-06*
