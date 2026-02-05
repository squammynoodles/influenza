# Requirements: Influenza

**Defined:** 2026-02-05
**Core Value:** Users can visually see when an influencer made a call and what the price did after

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Authentication

- [x] **AUTH-01**: User can create account with email and password
- [x] **AUTH-02**: Admin can invite users (invite-only access)
- [x] **AUTH-03**: User can reset password via email link
- [x] **AUTH-04**: User session persists across browser refresh

### Influencer Management

- [x] **INFL-01**: Admin can add new influencers to track
- [x] **INFL-02**: Admin can remove influencers from tracking
- [x] **INFL-03**: Influencer has profile (name, avatar, bio)
- [x] **INFL-04**: Influencer can have linked YouTube channel
- [x] **INFL-05**: Influencer can have linked Twitter/X account
- [x] **INFL-06**: User can browse list of all tracked influencers

### Content Ingestion

- [x] **CONT-01**: System pulls videos from linked YouTube channels
- [x] **CONT-02**: System extracts transcripts from YouTube videos
- [x] **CONT-03**: System pulls tweets from linked Twitter/X accounts
- [x] **CONT-04**: Content is processed in hourly batches
- [x] **CONT-05**: User can view content history for an influencer

### Call Extraction

- [x] **CALL-01**: System automatically detects calls from content using NLP/LLM
- [x] **CALL-02**: Calls are classified as bullish or bearish
- [x] **CALL-03**: Calls have confidence score (how certain the extraction is)
- [x] **CALL-04**: Calls identify the asset/ticker being called (BTC, ETH, NASDAQ, etc.)
- [x] **CALL-05**: Calls store timestamp, source link, and quote snippet

### Charts & Visualization

- [ ] **CHRT-01**: Interactive price chart with zoom, pan, and scroll
- [ ] **CHRT-02**: Chart supports multiple timeframes (1D, 1W, 1M, 3M, 1Y)
- [ ] **CHRT-03**: Call overlays appear as markers on the chart at correct price/time
- [ ] **CHRT-04**: Overlay markers show direction (bullish/bearish) via color/icon
- [ ] **CHRT-05**: Hovering over overlay shows call preview snippet
- [ ] **CHRT-06**: Clicking overlay shows full details (quote, source link, timestamp)
- [ ] **CHRT-07**: Dropdown to switch between assets the influencer has called
- [ ] **CHRT-08**: Charts support both crypto (BTC, ETH) and macro (NASDAQ) assets

### Price Data

- [x] **PRCE-01**: Modular price adapter architecture (swap providers without code changes)
- [x] **PRCE-02**: CoinGecko adapter for crypto price data
- [x] **PRCE-03**: Yahoo Finance adapter for macro price data (NASDAQ, S&P)
- [x] **PRCE-04**: Historical price data for chart rendering

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### User-Added Influencers

- **PAID-01**: User can add their own influencers to track (paid tier)
- **PAID-02**: System backfills historical content for user-added influencers

### Call Analysis

- **ANLZ-01**: System scores call accuracy (did price move in predicted direction?)
- **ANLZ-02**: User can see influencer accuracy metrics over time
- **ANLZ-03**: User can filter calls by accuracy outcome

### Additional Sources

- **SRCE-01**: Telegram channel ingestion
- **SRCE-02**: Discord server ingestion
- **SRCE-03**: Substack/newsletter ingestion

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Real-time call detection | Batch processing sufficient for v1, reduces complexity |
| User-submitted influencers | Quality control issues, requires paid tier infrastructure |
| Call accuracy scoring | Legal/complexity risks, defer to v2 after validation |
| Auto-trading/signal copying | Massive liability, never building this |
| Social features (comments, sharing) | Scope creep, moderation burden |
| Native mobile app | Web-first, responsive design sufficient |
| Public registration | Invite-only for v1, controlled user base |
| Historical call editing | Destroys trust, calls are immutable |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 | Complete |
| AUTH-02 | Phase 1 | Complete |
| AUTH-03 | Phase 1 | Complete |
| AUTH-04 | Phase 1 | Complete |
| INFL-01 | Phase 2 | Complete |
| INFL-02 | Phase 2 | Complete |
| INFL-03 | Phase 2 | Complete |
| INFL-04 | Phase 2 | Complete |
| INFL-05 | Phase 2 | Complete |
| INFL-06 | Phase 2 | Complete |
| CONT-01 | Phase 2 | Complete |
| CONT-02 | Phase 2 | Complete |
| CONT-03 | Phase 2 | Complete |
| CONT-04 | Phase 2 | Complete |
| CONT-05 | Phase 2 | Complete |
| CALL-01 | Phase 3 | Complete |
| CALL-02 | Phase 3 | Complete |
| CALL-03 | Phase 3 | Complete |
| CALL-04 | Phase 3 | Complete |
| CALL-05 | Phase 3 | Complete |
| PRCE-01 | Phase 3 | Complete |
| PRCE-02 | Phase 3 | Complete |
| PRCE-03 | Phase 3 | Complete |
| PRCE-04 | Phase 3 | Complete |
| CHRT-01 | Phase 4 | Pending |
| CHRT-02 | Phase 4 | Pending |
| CHRT-03 | Phase 4 | Pending |
| CHRT-04 | Phase 4 | Pending |
| CHRT-05 | Phase 4 | Pending |
| CHRT-06 | Phase 4 | Pending |
| CHRT-07 | Phase 4 | Pending |
| CHRT-08 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 32 total
- Mapped to phases: 32
- Unmapped: 0 ✓

---
*Requirements defined: 2026-02-05*
*Last updated: 2026-02-06 after Phase 3 completion*
