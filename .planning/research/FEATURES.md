# Feature Research

**Domain:** Influencer/Financial Call Tracking Platform
**Researched:** 2026-02-05
**Confidence:** MEDIUM

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Price chart visualization | Core value - without charts, can't overlay calls | MEDIUM | TradingView-style interactive charts are the standard. Users expect candlestick/line charts, zoom, pan, multiple timeframes |
| Influencer profiles | Users need to browse and select influencers to follow | LOW | Basic profile with bio, follower count, platforms, recent calls. Similar to analyst profiles on TipRanks |
| Call timeline/history | Must see all calls an influencer made over time | LOW | Chronological list of calls with asset, date, direction (bullish/bearish), price at call |
| Call overlay on charts | Core value - visualize when call was made vs price action | MEDIUM | Event markers/annotations on price chart at the timestamp of the call. This is the key differentiator users come for |
| Content source links | Users need to verify calls came from real content | LOW | Link back to original YouTube video or Twitter/X post where call was made |
| Basic filtering | Users need to find specific assets/influencers | LOW | Filter by asset (BTC, ETH, etc.), influencer, timeframe, call direction |
| User authentication | Invite-only requires user accounts | LOW | Standard email/password auth. Invite codes for access control |
| Mobile responsiveness | Users will check calls on mobile devices | MEDIUM | Charts and overlays must work on mobile. TradingView sets the standard here |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Multi-source call extraction | Automatically finds calls from YouTube + Twitter | HIGH | Requires content scraping/monitoring, NLP to identify "calls" from influencer content. Key tech challenge |
| Interactive chart with call overlays | Visual correlation between call timing and price action | MEDIUM | This IS the core value prop. Users can see at a glance what happened after the call |
| Influencer-first navigation | Browse by influencer rather than asset | LOW | Different mental model than most trading platforms (which are asset-first). Matches user intent: "show me what [influencer] has been saying" |
| Call context snippets | Show quote/clip from content where call was made | MEDIUM | Text snippet or video timestamp. Helps users understand the reasoning behind the call |
| Timestamp precision | Show exact timestamp when call was made | LOW | Important for crypto where prices move fast. "Called BTC at 3:24 PM" vs just "January 5th" |
| Admin-curated influencers | Quality control - only track credible influencers | LOW | Prevents garbage/spam influencers. Builds trust. Manual curation as a feature |
| Comparison view | Compare multiple influencers side-by-side | MEDIUM | See which influencers called the same asset at different times. Requires additional UI complexity |
| Call type classification | Categorize calls (entry, exit, TP, SL, DCA, etc.) | MEDIUM | Adds semantic meaning to calls. "This was an entry call" vs "this was a take-profit level" |
| Performance indicators (V2) | Show simple metrics like "called at $X, now at $Y" | MEDIUM | Defer to V2 per project context, but users will want this. Keep it simple - not full accuracy scoring yet |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| User-submitted influencers (V1) | Users want to track their favorite influencers | Quality control nightmare, spam, moderation overhead, legal liability for bad actors | Admin-curated only for V1. Gate user submissions behind paid tier in V2+ after platform is proven |
| Real-time call detection | Users want calls the instant they're posted | Massive infrastructure complexity, API rate limits, costs spike, adds little value (most calls are for days/weeks ahead) | Batch processing every 15-30 minutes is sufficient. Crypto moves fast but not THAT fast for strategic calls |
| Comprehensive accuracy scoring (V1) | Users want to know "who's most accurate" | Complex to calculate fairly (holding periods, cherry-picking, survivorship bias), opens platform to disputes/legal issues, requires significant data | Defer to V2+. Focus on visualization in V1. Let users judge with their eyes |
| Auto-trading / signal copying | Users want to copy trades automatically | Massive legal/regulatory liability, requires broker integrations, not core value prop | Explicitly don't build. This is a tracking/research tool, not a trading bot |
| Social features (comments, likes, follows) | Users want to discuss calls | Turns into a social network, moderation nightmare, distracts from core value | Keep it read-only. Users can discuss on the original Twitter/YouTube content |
| All possible content sources | "Also track Telegram, Discord, Reddit, podcasts, etc." | Each source requires custom scraping/API integration, returns diminish after YouTube + Twitter | YouTube + Twitter only for V1. These are public, scrapable, and where most influencers post |
| Historical call editing | "I want to update my call after the fact" | Destroys trust, enables fraud, impossible to audit | Calls are immutable once extracted. Timestamp and source link prove authenticity |
| Price predictions with targets | "Show predicted price $X by date Y" | Most influencer calls are vague ("bullish on BTC"), not specific predictions. Overfitting data | Extract direction and general timing only. Don't force precision that doesn't exist |

## Feature Dependencies

```
[User Authentication]
    └──enables──> [User Accounts]
                      └──enables──> [Invite-only Access]

[Content Source Monitoring (YouTube + Twitter)]
    └──requires──> [Call Extraction]
                      └──requires──> [Call Timeline]
                                        └──enables──> [Call Overlay on Charts]

[Influencer Profiles]
    └──enables──> [Influencer-first Navigation]
    └──enables──> [Call Timeline per Influencer]

[Price Chart Visualization]
    └──required-by──> [Call Overlay on Charts]
    └──enables──> [Basic Filtering (timeframe)]

[Admin-seeded Influencers]
    └──required-by-V1──> [Call Extraction]
    └──blocks──> [User-added Influencers] (V2+ feature)

[Call Overlay on Charts]
    └──enhances──> [Call Context Snippets]
    └──enhances──> [Comparison View]
```

### Dependency Notes

- **Call Overlay requires Price Charts:** Can't overlay calls without a chart to overlay them on. Chart implementation must come first.
- **Call Extraction requires Content Monitoring:** Must scrape/monitor YouTube + Twitter to extract calls. This is the data pipeline foundation.
- **Influencer-first Navigation requires Influencer Profiles:** Profile pages are the landing point for this navigation model.
- **Admin-curated conflicts with User-submitted (V1):** V1 is explicitly admin-only to maintain quality. User submissions deferred to V2+ behind paywall.
- **Accuracy Scoring requires Call Extraction + Historical Prices:** Can't score accuracy until you have calls + price data to compare. V2+ feature.

## MVP Definition

### Launch With (V1)

Minimum viable product — what's needed to validate the concept: "Users can visually see when an influencer made a call and what the price did after."

- [x] **User Authentication (invite-only)** — Requirement per project context. Email/password, invite codes only
- [x] **Admin-seeded Influencers (5-10)** — Quality over quantity. Manually curated list of credible influencers
- [x] **YouTube + Twitter Content Monitoring** — Automated monitoring of influencer posts/videos for new content
- [x] **Call Extraction** — NLP/rules-based extraction of "calls" from content (asset, direction, timestamp)
- [x] **Price Chart Visualization** — Interactive charts (TradingView-style) with zoom, pan, timeframes
- [x] **Call Overlay on Charts** — Event markers showing when calls were made, overlaid on price action
- [x] **Influencer Profiles** — Basic profile page with bio, platforms, call history
- [x] **Influencer-first Navigation** — Browse by influencer, see their call timeline
- [x] **Call Timeline/History** — Chronological list of all calls per influencer
- [x] **Content Source Links** — Link to original YouTube/Twitter post for verification
- [x] **Basic Filtering** — Filter by asset, influencer, timeframe, call direction

### Add After Validation (V1.x)

Features to add once core is working and users are engaged.

- [ ] **Call Context Snippets** — Trigger: Users ask "why did they make this call?" Show quote or video timestamp
- [ ] **Timestamp Precision** — Trigger: Users complain about vague call timing. Add exact timestamp display
- [ ] **Call Type Classification** — Trigger: Users want to distinguish entry vs exit vs TP. Add manual/auto tagging
- [ ] **Comparison View** — Trigger: Users ask to compare influencers. Build side-by-side comparison UI
- [ ] **Simple Performance Indicators** — Trigger: Users ask "is this call up or down?" Show "Called at $X, now $Y" (+/- %)
- [ ] **Multi-asset Charts** — Trigger: Users want to see multiple assets at once. Add multi-chart view
- [ ] **Export/Share Features** — Trigger: Users want to share findings. Add shareable links, screenshot exports
- [ ] **Email Notifications** — Trigger: Users want alerts for new calls. Add opt-in email digests

### Future Consideration (V2+)

Features to defer until product-market fit is established.

- [ ] **User-added Influencers (paid tier)** — Why defer: Quality control, moderation overhead. Paywall mitigates spam
- [ ] **Call Accuracy Analysis/Scoring** — Why defer: Complex, contentious, legal risk. Needs mature dataset and clear methodology
- [ ] **Additional Content Sources (Telegram, Discord, podcasts)** — Why defer: Diminishing returns, integration complexity
- [ ] **Portfolio Tracking** — Why defer: Scope creep. This is a research tool, not a portfolio manager
- [ ] **AI-powered Call Detection** — Why defer: Current ML models aren't reliable enough. Start with rules + manual review
- [ ] **API for 3rd-party Access** — Why defer: Security, rate limiting, pricing complexity. Build after core product is proven
- [ ] **Advanced Analytics Dashboard** — Why defer: Need more data to know what analytics matter to users
- [ ] **Influencer Leaderboards/Rankings** — Why defer: Contentious, requires accuracy scoring, legal/reputation risk

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Call Overlay on Charts | HIGH | MEDIUM | P1 |
| Price Chart Visualization | HIGH | MEDIUM | P1 |
| Call Extraction | HIGH | HIGH | P1 |
| YouTube + Twitter Monitoring | HIGH | HIGH | P1 |
| Influencer Profiles | HIGH | LOW | P1 |
| User Authentication | MEDIUM | LOW | P1 |
| Call Timeline/History | HIGH | LOW | P1 |
| Influencer-first Navigation | MEDIUM | LOW | P1 |
| Content Source Links | MEDIUM | LOW | P1 |
| Basic Filtering | HIGH | LOW | P1 |
| Call Context Snippets | MEDIUM | MEDIUM | P2 |
| Comparison View | MEDIUM | MEDIUM | P2 |
| Call Type Classification | MEDIUM | MEDIUM | P2 |
| Simple Performance Indicators | HIGH | MEDIUM | P2 |
| Timestamp Precision | LOW | LOW | P2 |
| Call Accuracy Scoring | HIGH | HIGH | P3 |
| User-added Influencers | MEDIUM | HIGH | P3 |
| Additional Content Sources | LOW | HIGH | P3 |
| Auto-trading | LOW | HIGH | NEVER |

**Priority key:**
- P1: Must have for launch (V1)
- P2: Should have, add when possible (V1.x)
- P3: Nice to have, future consideration (V2+)
- NEVER: Anti-feature, explicitly avoid

## Competitor Feature Analysis

| Feature | TipRanks (Stock Analysts) | LunarCrush (Crypto Social) | TradingView (Charts) | Our Approach |
|---------|--------------------------|----------------------------|----------------------|--------------|
| Analyst/Influencer Tracking | Yes - tracks 8,000+ analysts | Yes - tracks social sentiment | No - user-generated ideas only | Yes - curated 5-10 influencers (V1) |
| Performance Metrics | Yes - success rate, avg return, statistical significance | Yes - sentiment scores, social engagement | No | Defer to V2 (simple indicators in V1.x) |
| Call/Prediction Timeline | Yes - timestamped ratings/targets | No - aggregate sentiment only | Yes - user ideas with timestamps | Yes - core feature |
| Chart Visualization | Basic - links to broker charts | Yes - price + sentiment overlay | Yes - industry-leading charts | Yes - TradingView-style with call overlays |
| Content Source Links | No - proprietary analyst data | No - aggregate of social platforms | Yes - links to user profiles | Yes - links to YouTube/Twitter source |
| Multi-source Aggregation | Yes - tracks analysts across firms | Yes - tracks Twitter, Reddit, news | No | Yes - YouTube + Twitter for V1 |
| User-generated Content | No | No | Yes - anyone can post ideas | No - admin-curated only (V1) |
| Accuracy Scoring | Yes - transparent methodology | No | No | Defer to V2 |
| Filtering/Search | Yes - by analyst, stock, sector | Yes - by coin, sentiment, influencer | Yes - by asset, user, strategy | Yes - by influencer, asset, timeframe |
| Mobile App | Yes | Yes | Yes | Responsive web (V1), native app (V2+) |

**Key Differentiators from Competitors:**
1. **TipRanks** tracks professional analysts with firm affiliations. We track crypto/finance influencers (less formal, more social).
2. **LunarCrush** aggregates sentiment but doesn't show individual influencer call timelines. We focus on individual influencer credibility.
3. **TradingView** has user-generated ideas but no tracking of specific influencers over time. We track specific influencers systematically.
4. **Our unique value:** Visual overlay of influencer calls on price charts, showing exactly when they made the call and what happened after.

## Research Insights

### Table Stakes Are Lower Than Expected

Unlike professional stock platforms (TipRanks), crypto influencer tracking is a less mature space. Users don't expect:
- Real-time data (batch updates every 15-30 min is fine)
- Mobile apps (responsive web is sufficient for V1)
- Comprehensive accuracy scoring (visual comparison is enough initially)

This works in our favor - we can launch with less and still meet expectations.

### The Core Value is Visual, Not Analytical

Users want to SEE when calls were made vs what happened. They don't need complex metrics initially - the chart tells the story. This means:
- Invest in chart UX/visualization quality
- Defer analytics/scoring to V2
- Keep V1 focused on the visual overlay feature

### Admin Curation is a Feature, Not a Limitation

In a space full of spam and pump-and-dump influencers, admin curation builds trust. Users will accept (even prefer) a smaller list of credible influencers over a large list of questionable ones.

### YouTube + Twitter is Sufficient

Most serious crypto/finance influencers post on YouTube (long-form analysis) and Twitter (real-time takes). Telegram/Discord are more private and harder to scrape. Starting with public, scrapable sources is the right call.

### Call Extraction is the Hard Part

The technical challenge is reliably extracting "calls" from free-form content:
- "I'm bullish on BTC here" = call
- "BTC looks interesting" = not a call?
- "Took profits on ETH" = exit call
- "If BTC breaks $50k, I'm buying" = conditional call?

This requires either:
- Sophisticated NLP (expensive, error-prone)
- Manual review/flagging (doesn't scale)
- Hybrid approach (NLP + manual verification)

Recommend: Start with simple keyword matching + manual review for V1. Improve with ML in V2 as dataset grows.

## Sources

**Crypto Influencer Tracking & Marketing:**
- [Crypto Influencer Marketing Guide 2026](https://ninjapromo.io/crypto-influencer-marketing)
- [Best Influencer Crypto Campaigns Tools 2025](https://www.naughtymarketing.agency/post/best-influencer-crypto-campaigns-tools-software-comprehensive-2025-review)
- [Crypto Influencer Index](http://cryptoinfluencerindex.com/) - Measures accuracy of influencer tweets

**Analyst Performance Tracking (Comparable Platforms):**
- [TipRanks Review](https://tickernerd.com/resources/tipranks-review/) - How analyst performance is tracked
- [How TipRanks Ranks Analysts](https://www.tipranks.com/experts/how-experts-ranked) - Success rate, avg return, statistical significance

**Chart Visualization & Overlays:**
- [TradingView Advanced Charts](https://www.mindmathmoney.com/articles/tradingview-tutorial-2026-the-complete-beginners-guide-to-mastering-charts)
- [TradingView Social Features](https://www.tradingview.com/social-network/)
- [Chart Timeline Overlays](https://datavizcatalogue.com/blog/chart-combinations-timelines/)

**Social Media Content Tracking:**
- [Social Media Scraping 2026](https://scrapfly.io/blog/posts/social-media-scraping)
- [Best Social Media Scraping APIs 2026](https://www.capturekit.dev/blog/best-social-media-scraping-apis)
- [LunarCrush Social Intelligence](https://lunarcrush.com/)

**Portfolio & Signal Tracking:**
- [Best Crypto Alerts Apps 2026](https://tradersunion.com/interesting-articles/best-crypto-signals-top-8-free-providers/best-crypto-alerts-tu/)
- [Crypto Portfolio Tracker Apps](https://www.softwaretestinghelp.com/crypto-portfolio-tracker-apps/)
- [Social Trading Signal Providers](https://www.socialtradertools.com/signal-provider/)

**Influencer Comparison & Analytics:**
- [Compare Influencers Side by Side - HypeAuditor](https://hypeauditor.com/reports/account-comparison/)
- [Instagram Influencer Comparison - BrandID](https://brandid.app/compare-instagram-influencers/)
- [Influencer Discovery Tools 2025](https://mightyscout.com/blog/influencer-discovery-the-best-tools-in-2024-to-elevate-your-influencer)

**Authentication & Access Control:**
- [How to Create Invite-Only Auth Flow](https://supertokens.com/blog/how-to-create-an-invite-only-auth-flow)
- [Invitation System Setup](https://help.prefinery.com/article/131-how-to-invite-users)

---
*Feature research for: Influencer/Financial Call Tracking Platform*
*Researched: 2026-02-05*
*Confidence: MEDIUM - Based on web search of comparable platforms (TipRanks, LunarCrush, TradingView, crypto tracking tools). No direct competitors found that exactly match this concept, which suggests a market gap.*
