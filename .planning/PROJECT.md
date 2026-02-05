# Influenza

## What This Is

An influencer tracking platform that captures crypto and macro market calls from content sources (YouTube, X/Twitter), processes them to extract directional statements, and displays them as interactive overlays on price charts. Users can select an influencer, view a chart of any coin/asset they've called, and see exactly when and what they said overlaid on the price action.

## Core Value

Users can visually see when an influencer made a call and what the price did after — cutting through hype to reveal who actually knows what they're talking about.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] User accounts with email/password (admin invites users)
- [ ] Admin can seed influencers to track (5-10 for v1)
- [ ] Pull content from YouTube (video transcription + analysis)
- [ ] Pull content from X/Twitter (tweet parsing)
- [ ] Process content to extract directional calls (bullish/bearish, buy/sell)
- [ ] Store calls with timestamp, coin/asset, direction, source link, and quote
- [ ] Influencer-first navigation (pick influencer → see chart)
- [ ] Interactive price chart (TradingView-style)
- [ ] Chart overlays showing calls at price/time with direction indicator
- [ ] Hover overlay for call preview (snippet of what they said)
- [ ] Click overlay for full details (source link, full quote)
- [ ] Dropdown to switch between coins/assets an influencer has called
- [ ] Modular price data adapters (start with free APIs, swap to paid without code changes)
- [ ] Hourly batch processing for YouTube content
- [ ] Support crypto coins and macro assets (NASDAQ, etc.)

### Out of Scope

- User-added influencers (paid tier, future) — requires historical data backfill, costly
- Call accuracy analysis (tops/bottoms scoring) — v2 feature
- Telegram as content source — defer to after YouTube + X/Twitter working
- Real-time processing — batch is sufficient for v1
- Public access — invite-only for v1
- Mobile app — web-first

## Context

- Target influencers include crypto personalities like Ivan on Tech
- Tweets can be parsed directly ("Buy bitcoin" = clear call)
- YouTube requires transcription + LLM/parsing to extract calls from longer content
- Price data needs to cover both crypto (BTC, ETH, SOL) and traditional markets (NASDAQ)
- User base for v1 is small (personal + invited users)

## Constraints

- **Backend stack**: Ruby on Rails — familiar, productive
- **Frontend stack**: Next.js — SEO-optimized for future public release
- **Backend hosting**: Railway.com — deployment target
- **Frontend hosting**: TBD (Railway or Vercel)
- **Content sources**: YouTube and X/Twitter only for v1
- **Influencer count**: 5-10 seeded by admin for v1

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Rails + Next.js | Rails for rapid backend dev, Next.js for SEO when site goes public | — Pending |
| Influencer-first navigation | Users care about specific people, not browsing all calls | — Pending |
| Modular price adapters | Start free, upgrade to paid without architectural changes | — Pending |
| Batch processing for YouTube | Hourly is sufficient, simplifies architecture | — Pending |
| Invite-only auth | Small user base for v1, no need for public registration | — Pending |

---
*Last updated: 2026-02-05 after initialization*
