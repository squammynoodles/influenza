---
phase: 03-call-extraction-price-data
plan: 02
subsystem: api
tags: [rails, openai, gpt-4o-mini, llm, extraction, background-jobs, solid-queue]

# Dependency graph
requires:
  - phase: 03-call-extraction-price-data
    provides: "Asset, Call models with associations; extraction_status on Content"
  - phase: 02-influencer-content-pipeline
    provides: "Content model (YoutubeVideo, Tweet STI) with transcript and body fields"
provides:
  - "Calls::ExtractionService orchestrating GPT-4o-mini call extraction per content item"
  - "Calls::PromptBuilder with structured system prompt, supported asset list, negative examples"
  - "Calls::CallParser parsing LLM JSON into Call records with asset lookup"
  - "ExtractCallsJob for per-content extraction with retry on API errors"
  - "ExtractAllPendingCallsJob batch dispatcher for unprocessed content"
  - "Recurring schedule: extraction at :15 past the hour (staggered after ingestion)"
affects:
  - 03-03 (price fetching complements call extraction)
  - 03-04 (deployment needs OPENAI_API_KEY env var)
  - 04-chart-dashboard (charts display extracted calls)

# Tech tracking
tech-stack:
  added:
    - "ruby-openai ~> 8.3 (OpenAI API client for GPT-4o-mini)"
  patterns:
    - "LLM extraction with JSON mode (response_format: json_object)"
    - "Confidence threshold filtering (>= 0.7 to persist, >= 0.5 from LLM)"
    - "extraction_status state machine (pending -> completed/no_calls/low_confidence/no_transcript/no_content/failed)"
    - "Batch dispatcher + per-item job pattern for extraction pipeline"

key-files:
  created:
    - api/app/services/calls/extraction_service.rb
    - api/app/services/calls/prompt_builder.rb
    - api/app/services/calls/call_parser.rb
    - api/app/jobs/extract_calls_job.rb
    - api/app/jobs/extract_all_pending_calls_job.rb
  modified:
    - api/Gemfile
    - api/Gemfile.lock
    - api/config/recurring.yml

key-decisions:
  - "GPT-4o-mini for extraction (cost-effective at $0.15/1M input tokens)"
  - "Confidence >= 0.7 threshold for persisting calls; 0.5-0.7 marked low_confidence"
  - "50K character truncation limit for content sent to LLM"
  - "Temperature 0.1 for deterministic extraction"
  - "Extraction at :15 past hour, staggered after YouTube (:00) and Twitter (:30) ingestion"

patterns-established:
  - "Service orchestration: ExtractionService -> PromptBuilder + CallParser"
  - "Batch dispatcher job pattern: ExtractAllPendingCallsJob -> ExtractCallsJob"
  - "extraction queue for LLM processing jobs"

# Metrics
duration: 2min
completed: 2026-02-06
---

# Phase 3 Plan 2: Call Extraction Pipeline Summary

**GPT-4o-mini call extraction pipeline with ruby-openai, structured prompts for 15 supported assets, JSON mode parsing into Call records, and hourly batch scheduling via Solid Queue**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-05T19:17:08Z
- **Completed:** 2026-02-05T19:19:27Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Built three-class extraction service layer: PromptBuilder (system/user prompts with 15 supported assets, negative examples, JSON format), CallParser (LLM JSON to Call records with asset lookup), ExtractionService (orchestrates LLM call, parsing, confidence filtering, status updates)
- Created per-content extraction job with retry on Faraday errors and batch dispatcher for pending content
- Added recurring schedule staggered at :15 past the hour after ingestion jobs

## Task Commits

Each task was committed atomically:

1. **Task 1: Add ruby-openai gem and create call extraction services** - `78df682` (feat)
2. **Task 2: Create extraction background jobs and recurring schedule** - `3279ac8` (feat)

## Files Created/Modified
- `api/app/services/calls/prompt_builder.rb` - System/user prompt construction with supported asset list and negative examples
- `api/app/services/calls/call_parser.rb` - Parses LLM JSON response into Call records with asset lookup and validation
- `api/app/services/calls/extraction_service.rb` - Orchestrates OpenAI API call, parsing, confidence filtering, and extraction_status updates
- `api/app/jobs/extract_calls_job.rb` - Per-content extraction job with retry on Faraday errors, discard on not found
- `api/app/jobs/extract_all_pending_calls_job.rb` - Batch dispatcher finding pending/nil extraction_status content
- `api/Gemfile` - Added ruby-openai ~> 8.3
- `api/Gemfile.lock` - Updated with ruby-openai and faraday-multipart dependencies
- `api/config/recurring.yml` - Added extract_all_pending_calls to production (:15) and development (every 10 min)

## Decisions Made
- GPT-4o-mini selected over GPT-4o for cost efficiency ($0.15 vs $2.50 per 1M input tokens) -- sufficient for extraction tasks
- Confidence >= 0.7 to persist Call records; 0.5-0.7 from LLM but filtered at service layer, content marked "low_confidence"
- 50,000 character truncation limit prevents token cost blowout on long transcripts
- Temperature 0.1 for deterministic, consistent extraction
- Extraction runs at :15 past the hour, after YouTube (:00) and Twitter (:30) have time to ingest content

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required

**OPENAI_API_KEY** must be set in production for call extraction to work.
- Source: OpenAI Platform -> API keys (https://platform.openai.com/api-keys)
- Required for: GPT-4o-mini call extraction from content

## Next Phase Readiness
- Call extraction pipeline complete and ready for production use once OPENAI_API_KEY is set
- Price data fetching (03-03) can proceed independently
- All 15 supported assets are already seeded from 03-01
- Extraction schedule integrates with existing ingestion schedule (YouTube :00, Twitter :30, Extraction :15)

---
*Phase: 03-call-extraction-price-data*
*Completed: 2026-02-06*
