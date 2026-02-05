# Roadmap: Influenza

## Overview

Transform influencer social media content into actionable insights by building a full-stack platform that ingests YouTube videos and Twitter posts, extracts market calls using NLP, and visualizes them as interactive overlays on price charts. Four phases deliver foundation → content pipeline → intelligence extraction → user-facing visualization, enabling users to see exactly when influencers made calls and what prices did afterward.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation & Authentication** - Rails API, Next.js frontend, user accounts, deployment infrastructure
- [ ] **Phase 2: Influencer & Content Pipeline** - Admin influencer management, YouTube/Twitter ingestion with batch processing
- [ ] **Phase 3: Call Extraction & Price Data** - NLP-based call extraction from content, modular price data integration
- [ ] **Phase 4: Chart Visualization** - Interactive charts with call overlays, complete user experience

## Phase Details

### Phase 1: Foundation & Authentication
**Goal**: Users can create accounts and access authenticated platform with deployed infrastructure
**Depends on**: Nothing (first phase)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04
**Success Criteria** (what must be TRUE):
  1. User can create account with email and password
  2. User can log in and session persists across browser refresh
  3. User can reset password via email link
  4. Admin can invite users to platform (invite-only access)
  5. Rails API and Next.js frontend are deployed and accessible
**Plans**: TBD

Plans:
- [ ] 01-01: TBD during plan-phase

### Phase 2: Influencer & Content Pipeline
**Goal**: Admin can manage influencers and system automatically ingests content from YouTube and Twitter
**Depends on**: Phase 1
**Requirements**: INFL-01, INFL-02, INFL-03, INFL-04, INFL-05, INFL-06, CONT-01, CONT-02, CONT-03, CONT-04, CONT-05
**Success Criteria** (what must be TRUE):
  1. Admin can add influencers with profile (name, avatar, bio)
  2. Admin can link YouTube channels and Twitter accounts to influencers
  3. Admin can remove influencers from tracking
  4. User can browse list of all tracked influencers
  5. System pulls videos from linked YouTube channels every hour
  6. System extracts transcripts from YouTube videos
  7. System pulls tweets from linked Twitter accounts every hour
  8. User can view content history for any influencer
**Plans**: TBD

Plans:
- [ ] 02-01: TBD during plan-phase

### Phase 3: Call Extraction & Price Data
**Goal**: System automatically extracts market calls from content and provides price data for all called assets
**Depends on**: Phase 2
**Requirements**: CALL-01, CALL-02, CALL-03, CALL-04, CALL-05, PRCE-01, PRCE-02, PRCE-03, PRCE-04
**Success Criteria** (what must be TRUE):
  1. System detects calls from YouTube transcripts and tweets using NLP
  2. Calls are classified as bullish or bearish with confidence scores
  3. Calls identify the asset being called (BTC, ETH, NASDAQ, etc.)
  4. Calls store timestamp, source link, and quote snippet
  5. System fetches historical price data for crypto assets via CoinGecko
  6. System fetches historical price data for macro assets via Yahoo Finance
  7. Price data adapters are swappable without code changes
**Plans**: TBD

Plans:
- [ ] 03-01: TBD during plan-phase

### Phase 4: Chart Visualization
**Goal**: Users see interactive price charts with influencer call overlays, completing the core value proposition
**Depends on**: Phase 3
**Requirements**: CHRT-01, CHRT-02, CHRT-03, CHRT-04, CHRT-05, CHRT-06, CHRT-07, CHRT-08
**Success Criteria** (what must be TRUE):
  1. User sees interactive price chart with zoom, pan, and scroll
  2. Chart supports multiple timeframes (1D, 1W, 1M, 3M, 1Y)
  3. Call overlays appear as markers on chart at correct price and time
  4. Overlay markers show direction via color/icon (bullish = green, bearish = red)
  5. Hovering over overlay shows call preview snippet
  6. Clicking overlay shows full details (quote, source link, timestamp)
  7. User can switch between assets the influencer has called via dropdown
  8. Charts work for both crypto (BTC, ETH) and macro (NASDAQ) assets
**Plans**: TBD

Plans:
- [ ] 04-01: TBD during plan-phase

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Authentication | 0/TBD | Not started | - |
| 2. Influencer & Content Pipeline | 0/TBD | Not started | - |
| 3. Call Extraction & Price Data | 0/TBD | Not started | - |
| 4. Chart Visualization | 0/TBD | Not started | - |

---
*Created: 2026-02-05*
*Last updated: 2026-02-05*
