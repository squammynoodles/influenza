# Pitfalls Research

**Domain:** Influencer Call Tracking / Financial Signal Extraction Platform
**Researched:** 2026-02-05
**Confidence:** MEDIUM-HIGH

## Critical Pitfalls

### Pitfall 1: YouTube API Quota Exhaustion Without Warning

**What goes wrong:**
Your platform silently stops ingesting new content because it hit YouTube's 10,000 units/day quota. Users see stale data, miss recent calls, and trust erodes. With 5-10 influencers posting multiple videos per week, quota burns faster than expected.

**Why it happens:**
Developers underestimate quota costs. A single `videos.list` call costs 1 unit, but fetching full video details with statistics costs more. Batch processing every hour means 24 fetches/day per influencer. With 10 influencers, that's 240+ units/day just for metadata—before you even fetch captions/transcripts. Add caption fetching (captions.download = 200 units), and you're at 2,000+ units/day for basic operations.

**How to avoid:**
- Implement quota tracking in your admin panel with alerts at 80% usage
- Use incremental fetching: only fetch new videos since last check (publishedAfter parameter)
- Cache video metadata and only refresh when needed
- Request quota extension early (requires 3-4 day approval process)
- Design your system to gracefully degrade: prioritize high-engagement influencers when quota is low

**Warning signs:**
- Quota usage climbing above 7,000 units/day
- Error logs showing 403 "quotaExceeded" responses
- Increasing time gaps between content updates
- User reports of "missing recent videos"

**Phase to address:**
Phase 1 (MVP) - Build quota monitoring from day one. Phase 2 - Implement smart caching and prioritization.

**Sources:**
- [YouTube API Quota Guide](https://developers.google.com/youtube/v3/guides/quota_and_compliance_audits)
- [YouTube API Quota Calculator](https://developers.google.com/youtube/v3/determine_quota_cost)
- [YouTube API Limits 2025](https://getlate.dev/blog/youtube-api-limits-how-to-calculate-api-usage-cost-and-fix-exceeded-api-quota)

---

### Pitfall 2: X/Twitter Rate Limits Without Token Rotation

**What goes wrong:**
Your platform gets rate-limited mid-ingestion, causing partial data updates. Some influencers' tweets get processed, others don't. Users see inconsistent data and can't trust that all calls are being tracked.

**Why it happens:**
X API has strict 15-minute windows for rate limits. A single OAuth token might only allow 180 requests per 15 minutes. If you're fetching tweets from 10 influencers with 50+ tweets each to scan, you'll hit limits before completing a full ingestion cycle. Unlike YouTube's daily quota, X's limits reset every 15 minutes but are much smaller per window.

**How to avoid:**
- Implement token rotation: use multiple OAuth tokens (2-4x increase in capacity)
- Add exponential backoff when you hit rate limits
- Monitor x-rate-limit-remaining and x-rate-limit-reset headers in EVERY response
- Pre-check rate limit status with GET /application/rate_limit_status before intensive operations
- Design batch jobs to pause and resume across multiple 15-minute windows

**Warning signs:**
- 429 "Rate Limit Exceeded" errors in logs
- Incomplete data for some influencers but not others
- Batch jobs timing out or failing inconsistently
- API response headers showing x-rate-limit-remaining near zero

**Phase to address:**
Phase 1 (MVP) - Implement rate limit monitoring and exponential backoff. Phase 2 - Add token rotation pool.

**Sources:**
- [X API Rate Limits](https://docs.x.com/x-api/fundamentals/rate-limits)
- [Rate Limiting Best Practices](https://moldstud.com/articles/p-best-practices-for-integrating-twitter-api-how-to-effectively-handle-rate-limits)
- [Twitter API Limits Guide 2025](https://www.gramfunnels.com/blog/twitter-api-limits)

---

### Pitfall 3: YouTube Auto-Caption Accuracy Below 62%

**What goes wrong:**
Your NLP extraction relies on YouTube's auto-generated captions, which are only ~62% accurate. Financial terms get mangled ("Bitcoin" becomes "big coin", "ETH" becomes "F"), ticker symbols are misheard ("NVDA" becomes "Nvidia"), and critical calls are missed entirely or extracted incorrectly.

**Why it happens:**
YouTube's auto-captions struggle with: accents, background music, technical jargon, fast speech, and overlapping audio. Financial influencers often use specialized terminology that auto-captioning wasn't trained on. Worse, some videos don't have auto-captions at all (creator disabled them, or YouTube couldn't generate them).

**How to avoid:**
- Fetch BOTH auto-captions AND manual captions if available (check caption tracks)
- Implement a confidence scoring system: flag extractions from auto-captions as "low confidence"
- Build a financial terminology correction layer: map common misheard terms ("big coin" → "Bitcoin")
- Consider third-party transcription services (Whisper API, Rev.ai) for high-value influencers
- Show users the source transcript snippet so they can verify accuracy themselves

**Warning signs:**
- User reports of "this call wasn't made" when reviewing the source video
- Extraction results with garbled ticker symbols or prices
- High percentage of videos with auto-captions vs. manual captions
- NLP extraction confidence scores consistently below 0.7

**Phase to address:**
Phase 1 (MVP) - Use auto-captions but flag them as "unverified". Phase 2 - Add manual caption preference and terminology correction. Phase 3 - Integrate professional transcription for top influencers.

**Sources:**
- [YouTube Auto Caption Accuracy Study](https://www.consumerreports.org/disability-rights/auto-captions-often-fall-short-on-zoom-facebook-and-others-a9742392879/)
- [YouTube Auto Caption Issues](https://www.dittotranscripts.com/blog/does-youtube-automatically-caption-videos/)
- [Caption Accuracy Requirements 2026](https://www.opus.pro/blog/youtube-shorts-caption-subtitle-best-practices)

---

### Pitfall 4: False Positive Call Extraction at 40-60%

**What goes wrong:**
Your NLP model extracts "calls" that aren't actually recommendations: "I'm NOT buying Bitcoin here" gets flagged as a BUY call. "People are talking about NVDA" becomes a recommendation. Users lose trust when half the "calls" are noise.

**Why it happens:**
Financial language is nuanced. Influencers discuss assets without recommending them, mention past calls, analyze what others are doing, or use conditional/hypothetical language. Basic NLP catches keywords ("buy", "Bitcoin") but misses negation ("don't buy"), hedging ("might buy"), or reporting ("others are buying"). This is the "false positive" problem that plagues financial NLP systems.

**How to avoid:**
- Implement negation detection: scan for "not", "don't", "won't", "never" before action words
- Build a multi-stage extraction pipeline: (1) keyword detection, (2) sentiment analysis, (3) intent classification
- Use context windows: analyze 2-3 sentences around the keyword, not just the sentence
- Add confidence thresholds: only show calls with >70% confidence score by default
- Let users adjust sensitivity: "strict mode" (fewer false positives) vs. "comprehensive mode" (more coverage)
- Include the original quote snippet for every call so users can judge for themselves

**Warning signs:**
- User feedback: "This isn't a real call"
- High number of extracted calls per video (>5-10 suggests over-extraction)
- Calls with weak action language ("discussing", "watching", "interesting")
- Low user engagement with extracted calls

**Phase to address:**
Phase 1 (MVP) - Use simple keyword + negation detection with confidence scores. Phase 2 - Implement intent classification. Phase 3 - Add LLM-based validation.

**Sources:**
- [NLP False Positives in Finance](https://www.johnsnowlabs.com/examining-the-impact-of-nlp-in-financial-services/)
- [Reducing False Positives in Financial NLP](https://www.phoenixstrategy.group/blog/nlp-fraud-detection-key-challenges-solutions)
- [Financial NLP Accuracy Challenges](https://chatfin.ai/blog/nlp-in-finance-natural-language-processing-for-financial-analysis-guide/)

---

### Pitfall 5: Ticker Symbol Disambiguation Failures

**What goes wrong:**
An influencer says "COIN" and you match it to Coinbase (COIN on NASDAQ), but they meant Bitcoin. Or they say "META" referring to the metaverse concept, not Meta Platforms stock. Or they mention "GO" as a verb, but your system flags GO on NYSE.

**Why it happens:**
Ticker symbols are ambiguous. Many common words are valid tickers: GO, AI, BIG, NOW, VERY, RACE, GOOD, NICE, LOVE. Without context, you can't tell if "AI is the future" is about Artificial Intelligence or C3.ai Inc (ticker: AI). Crypto adds more confusion: "BTC" vs. "Bitcoin" vs. "bitcoin" vs. "btc.x" across different exchanges.

**How to avoid:**
- Build a context-aware disambiguation engine: check surrounding words for market context
- Maintain a blocklist of common false-positive tickers: articles (A), prepositions (TO), common verbs (GO, RUN)
- Use ticker symbol formatting conventions: require "$" prefix ($NVDA) or all-caps in specific contexts
- Validate extracted tickers against a watchlist: only match symbols for assets the influencer typically covers
- For crypto: normalize to canonical symbols (BTC, ETH) and map exchange-specific variants
- Show the extraction context to users: "Found 'COIN' in: 'I think COIN will hit $300'"

**Warning signs:**
- High number of extracted calls for obscure tickers the influencer never covers
- Ticker extractions for common words in non-financial contexts
- User reports: "I never said to buy [X]"
- Extraction logs showing single-letter or two-letter tickers

**Phase to address:**
Phase 1 (MVP) - Use simple ticker validation (require $ prefix or all-caps + market context). Phase 2 - Add per-influencer watchlists and disambiguation. Phase 3 - Implement ML-based context analysis.

**Sources:**
- [Stock Symbol Recognition in Tweets](https://www.researchgate.net/publication/261832650_Recognition_of_NASDAQ_stock_symbols_in_tweets)
- [NLP Stock Ticker Extraction](https://encyclopedia.pub/entry/25229)
- [Context Issues in NLP Trading](https://www.skyriss.com/guides/using-natural-language-processing-nlp-for-trading-decisions)

---

### Pitfall 6: Timestamp Synchronization Nightmares

**What goes wrong:**
An influencer posts a YouTube video at 3 PM EST recommending Bitcoin. Your system records it as 3 PM UTC (8 hours off). The price chart shows BTC at $45K at your recorded time, but it was actually $44K when they made the call. Performance tracking is completely wrong.

**Why it happens:**
Multiple timestamp sources use different formats and timezones: YouTube API returns ISO 8601 with timezone, X API returns UTC timestamps, your Rails backend might use server local time, price APIs use exchange-specific timezones (NYSE = EST/EDT, crypto = UTC). DST changes add more chaos—twice a year, timestamps shift by an hour. Mixing these without careful conversion creates off-by-hours or off-by-days errors.

**How to avoid:**
- Store ALL timestamps in UTC in your database (use Rails' `datetime` with UTC zone)
- Convert to UTC immediately when ingesting from APIs: `Time.parse(timestamp).utc`
- Handle DST changes: use timezone-aware libraries (Rails' ActiveSupport::TimeZone)
- For display: convert to user's local timezone, but ALWAYS show timezone indicator ("3:00 PM EST")
- Add timestamp validation: reject timestamps in the future or >1 year old
- Test around DST transitions (March and November in US)

**Warning signs:**
- Calls showing times that don't match video publish time
- Price data offset by exactly 1, 4, 5, 8, or 13 hours (common timezone differences)
- Errors clustering around March/November (DST transitions)
- User reports: "This call was made at a different time"

**Phase to address:**
Phase 1 (MVP) - Enforce UTC storage and conversion. Phase 2 - Add timezone validation and testing.

**Sources:**
- [Timezone Best Practices for Databases](https://www.tinybird.co/blog/database-timestamps-timezones)
- [Common Timestamp Pitfalls](https://www.datetimeapp.com/learn/common-timestamp-pitfalls)
- [Financial Data Timezone Mistakes](https://medium.com/@kevinmenesesgonzalez/5-common-mistakes-in-financial-data-extraction-and-how-to-fix-them-40eb8545764d)

---

### Pitfall 7: Stale Price Data from Caching Gone Wrong

**What goes wrong:**
User sees "BTC is $50K" on the chart, but actual current price is $48K. They make decisions on stale data and lose trust in your platform. Or worse: batch job fetches price data hourly, but crypto moved 5% in the last 15 minutes.

**Why it happens:**
Price APIs are expensive (rate-limited or paid). To reduce costs, developers cache price data. But if cache TTL is too long (1 hour), data goes stale. If cache invalidation logic is buggy, old data persists. Crypto markets trade 24/7, stocks trade 9:30 AM - 4 PM EST. Using the same caching strategy for both creates problems—crypto needs fresher data.

**How to avoid:**
- Implement asset-class-specific cache TTLs: crypto = 1-5 minutes, stocks during market hours = 1 minute, stocks after-hours = 15 minutes
- Add cache freshness indicators in UI: "Last updated: 2 minutes ago"
- Use websocket price streams for high-priority assets instead of polling
- Implement stale data detection: if price hasn't changed in >N time windows, flag it
- Build a fallback chain: primary API → cache → secondary API
- During market volatility (>2% moves), reduce cache TTL automatically

**Warning signs:**
- Price data identical across multiple fetches (suggests cached/stale)
- User complaints about inaccurate prices
- API usage far below expected (suggests over-caching)
- Price updates stop during after-hours but cache keeps serving old data

**Phase to address:**
Phase 1 (MVP) - Implement basic caching with 5-minute TTL and freshness indicators. Phase 2 - Add asset-class-specific TTLs and websocket streams.

**Sources:**
- [Real-time vs Batch Data Tradeoffs](https://www.confluent.io/learn/batch-vs-real-time-data-processing/)
- [Crypto API Real-time Best Practices 2026](https://coinranking.com/blog/best-real-time-crypto-price-apis-in-2026-a-developer-guide/)
- [Data Freshness Challenges](https://streamkap.com/resources-and-guides/batch-vs-real-time-processing)

---

### Pitfall 8: Chart Rendering Performance Collapse with >1000 Data Points

**What goes wrong:**
User loads an influencer's profile showing 6 months of calls. Page freezes for 3-5 seconds. Browser tab crashes on mobile devices. Chart becomes unusable.

**Why it happens:**
TradingView charts (and similar libraries) struggle with large datasets. Rendering 1000+ candlesticks + custom overlays for each call + price lines creates thousands of DOM elements. JavaScript re-renders on every zoom/pan. With 10 influencers × 50 calls each × 180 days of price data, you're trying to render 5,000+ data points simultaneously.

**How to avoid:**
- Implement progressive loading: show recent 30 days by default, load more on zoom-out
- Use TradingView's "optimizeDataForSpeed" setting to reduce rendering detail
- Downsample historical data: daily candles for >90 days, hourly for 7-90 days, 15-min for <7 days
- Lazy-load charts: only render when scrolled into view (Intersection Observer)
- Limit visible overlays: show top 20 calls by default, let users expand for more
- Pre-aggregate data server-side instead of client-side processing
- Consider TradingView's Lightweight Charts library for simpler use cases (better performance)

**Warning signs:**
- Page load times >2 seconds for chart-heavy pages
- Browser console warnings about excessive re-renders
- Mobile browser crashes on chart pages
- High CPU usage in Chrome DevTools Performance profiler

**Phase to address:**
Phase 1 (MVP) - Limit data range to 30-90 days and use data downsampling. Phase 2 - Add progressive loading and lazy rendering.

**Sources:**
- [TradingView Performance Optimization](https://pineify.app/resources/blog/tradingview-running-slow-complete-guide-to-fix-lag-and-performance-issues)
- [TradingView Chart Troubleshooting](https://www.luxalgo.com/blog/ultimate-guide-to-tradingview-chart-troubleshooting/)
- [Lightweight Charts Feedback](https://github.com/tradingview/lightweight-charts/discussions/362)

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Store raw API responses in JSON columns without schema | Fast to implement, flexible | Can't query efficiently, schema drift, hard to migrate | MVP only—plan migration by Phase 2 |
| Skip caption/transcript validation | Faster ingestion, no API costs | High false positive rate, user trust issues | Never—always validate |
| Hardcode influencer list in code | No admin UI needed | Requires code deploy to add influencers, no scaling | Only for <5 influencers in early testing |
| Use single API token for all requests | Simple auth management | Hit rate limits instantly, single point of failure | MVP only—add rotation by Phase 2 |
| Poll for price updates every N seconds | Easy to implement with cron | High API costs, stale data between polls | Acceptable for MVP, switch to websockets Phase 2+ |
| Skip timezone normalization "because everything is UTC" | Less code, fewer conversions | Breaks with user-generated timestamps, DST issues | Never—always normalize |
| Cache price data indefinitely | Minimal API usage | Stale data, wrong performance metrics | Never—always set TTL |
| Extract all text, filter later | Complete data capture | High storage costs, slow queries | Acceptable if disk is cheap, unacceptable for >100K records |

---

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| YouTube API | Fetching full video details for every video every hour | Use `publishedAfter` to fetch only new videos; cache metadata |
| X/Twitter API | Ignoring rate limit headers until 429 error | Check `x-rate-limit-remaining` on EVERY response; pre-emptive backoff |
| Price APIs (crypto) | Assuming all exchanges report prices in USD | Check quote currency; normalize to common base (USD or USDT) |
| Price APIs (stocks) | Fetching real-time quotes during after-hours | Check market hours; use different endpoints for after-hours vs. regular |
| YouTube captions | Assuming captions always exist | Check caption track availability; handle missing captions gracefully |
| TradingView library | Loading entire price history into chart at once | Use progressive loading; fetch data on-demand as user zooms |
| Webhooks (if added later) | No retry mechanism for failed deliveries | Implement exponential backoff; dead-letter queue for failures |

---

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| N+1 queries for influencer + calls | Slow page loads, high DB CPU | Use eager loading: `includes(:calls)` in Rails | >50 influencers or >500 calls |
| Fetching all price data for chart in single query | Page timeout, large JSON payloads | Paginate or downsample; fetch visible range only | >1000 price points per chart |
| Re-processing entire transcript on every ingestion | Batch jobs take hours, quota waste | Track last processed timestamp; incremental updates | >100 videos per influencer |
| Storing high-frequency price ticks (1-second) | Massive DB growth, slow queries | Downsample: 1-min for crypto, 5-min for stocks | >10M price records |
| Running NLP extraction synchronously in web request | Request timeout, poor UX | Background jobs (Sidekiq); show "processing" state | >30-second extraction time |
| Full-text search on captions without indexing | Slow search, DB locks | Add full-text index (pg_search gem) or use Elasticsearch | >10K videos |
| Loading all influencers into memory | High memory usage, slow renders | Paginate influencer list; lazy-load details | >100 influencers |

---

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Exposing API keys in client-side JavaScript | Keys stolen, quota exhausted, account banned | All API calls server-side only; never send keys to browser |
| Not validating influencer YouTube/X handles | Admin adds malicious channel, scrapes unintended content | Validate channel/handle exists and is public before saving |
| Storing price data without attribution | Legal liability for redistributing exchange data | Include data source attribution; check ToS for redistribution rights |
| Allowing public API access to raw extraction data | Competitor scrapes your NLP results | Require authentication; rate-limit API endpoints |
| Not rate-limiting user requests for chart data | DoS via expensive chart renders | Implement per-user rate limits (e.g., 10 charts/minute) |
| Trusting user-provided timestamps | Injection attacks, data corruption | Validate timestamp format and range; reject future timestamps |
| Exposing internal influencer IDs in URLs | Enumeration attacks, data leaks | Use UUIDs or slugs instead of sequential integers |

---

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Showing all extracted calls without filtering | Information overload, can't find important calls | Default to high-confidence calls only; let users toggle "show all" |
| Not showing extraction confidence scores | Users can't judge reliability | Show confidence badges: "High", "Medium", "Low" |
| Hiding the original source context | Users can't verify calls are accurate | Always show quote snippet + link to source video at timestamp |
| Using absolute timestamps only ("2026-02-05 14:23 UTC") | Hard to judge recency at a glance | Use relative time: "2 hours ago" + absolute time on hover |
| Chart with no indication of call timing | Users can't correlate calls with price moves | Add vertical lines or annotations on chart at call timestamps |
| No explanation when data is missing | Users think platform is broken | Show status: "Processing...", "Caption unavailable", "API rate limited" |
| Overwhelming users with too many influencers | Analysis paralysis, can't focus | Start with 3-5 featured influencers; let users add more |
| Not showing price performance attribution | Users can't tell if calls were profitable | Show clear "+15%" or "-8%" badges for price change after call |

---

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Call extraction:** Often missing negation detection—verify "don't buy" is not flagged as BUY call
- [ ] **Timestamp handling:** Often missing timezone normalization—verify UTC storage and DST testing
- [ ] **Price data sync:** Often missing staleness detection—verify last-update timestamps and alerts
- [ ] **YouTube ingestion:** Often missing quota monitoring—verify tracking dashboard and 80% alert
- [ ] **X/Twitter ingestion:** Often missing rate-limit handling—verify exponential backoff on 429 errors
- [ ] **Chart rendering:** Often missing data downsampling—verify performance with 1000+ data points
- [ ] **Caption processing:** Often missing manual caption preference—verify checks for human-created captions first
- [ ] **Ticker extraction:** Often missing disambiguation—verify context analysis for ambiguous symbols
- [ ] **Batch jobs:** Often missing failure recovery—verify retry logic and dead-letter queues
- [ ] **API integrations:** Often missing health checks—verify monitoring and failover to secondary APIs

---

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| YouTube quota exhausted | LOW | Wait until midnight PT for reset; request quota increase for future (3-4 days) |
| False positive calls flooding feed | MEDIUM | Add confidence threshold filter; re-run extraction with improved logic; let users flag incorrect calls |
| Timezone data corrupted | HIGH | Identify affected records; re-fetch original timestamps from API; re-normalize to UTC; regenerate performance metrics |
| Stale price data cached | LOW | Flush cache; reduce TTL; add cache freshness validation |
| Chart performance collapse | MEDIUM | Implement data downsampling; add progressive loading; migrate to Lightweight Charts if needed |
| Ticker symbol misidentification | MEDIUM | Build disambiguation rules; re-extract affected calls; add user correction mechanism |
| API rate limit ban | HIGH | Contact API provider; explain use case; request exemption or higher tier; implement better rate limiting |
| Caption extraction failures | MEDIUM | Switch to manual captions where available; integrate third-party transcription service; flag as "unverified" |

---

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| YouTube quota exhaustion | Phase 1 (MVP) | Quota dashboard shows usage <7K/day; alerts trigger at 80% |
| X rate limit without rotation | Phase 1 (MVP) | Logs show no 429 errors; response headers monitored |
| YouTube caption accuracy <62% | Phase 1 (MVP: flag as unverified) | UI shows "unverified" badge on auto-caption extractions |
| False positive call extraction | Phase 1 (MVP: basic detection) | User feedback mechanism; <20% false positive rate |
| Ticker symbol disambiguation | Phase 1 (MVP: simple validation) | Manual review shows <10% disambiguation errors |
| Timestamp synchronization | Phase 1 (MVP: UTC enforcement) | All DB timestamps in UTC; DST tests pass |
| Stale price data | Phase 1 (MVP: basic caching) | UI shows freshness indicators; TTL ≤5 minutes |
| Chart rendering performance | Phase 1 (MVP: data limiting) | Page load <2s for 90 days of data |
| Caption preference (manual first) | Phase 2 | Logs show manual captions used when available |
| Token rotation for rate limits | Phase 2 | System handles 3-4x normal load without errors |
| NLP intent classification | Phase 2 | False positive rate drops to <10% |
| Websocket price streams | Phase 2-3 | Real-time updates without polling |
| Professional transcription integration | Phase 3 | Top influencers use high-accuracy transcripts |

---

## Sources

### API Documentation and Limits
- [YouTube API Quota Guide](https://developers.google.com/youtube/v3/guides/quota_and_compliance_audits)
- [YouTube API Quota Calculator](https://developers.google.com/youtube/v3/determine_quota_cost)
- [YouTube API Limits 2025](https://getlate.dev/blog/youtube-api-limits-how-to-calculate-api-usage-cost-and-fix-exceeded-api-quota)
- [X API Rate Limits](https://docs.x.com/x-api/fundamentals/rate-limits)
- [X API Best Practices](https://moldstud.com/articles/p-best-practices-for-integrating-twitter-api-how-to-effectively-handle-rate-limits)

### Content Ingestion and Accuracy
- [YouTube Auto Caption Accuracy Study](https://www.consumerreports.org/disability-rights/auto-captions-often-fall-short-on-zoom-facebook-and-others-a9742392879/)
- [Social Media Scraping Pitfalls 2026](https://scrapfly.io/blog/posts/social-media-scraping)
- [Influencer Tracking Mistakes](https://influencity.com/blog/en/top-5-influencer-marketing-tracking-mistakes-and-how-to-fix-them)

### NLP and Extraction
- [NLP False Positives in Finance](https://www.johnsnowlabs.com/examining-the-impact-of-nlp-in-financial-services/)
- [Financial NLP Accuracy Challenges](https://chatfin.ai/blog/nlp-in-finance-natural-language-processing-for-financial-analysis-guide/)
- [Stock Symbol Recognition in Tweets](https://www.researchgate.net/publication/261832650_Recognition_of_NASDAQ_stock_symbols_in_tweets)

### Price Data and Timing
- [Timezone Best Practices for Databases](https://www.tinybird.co/blog/database-timestamps-timezones)
- [Common Timestamp Pitfalls](https://www.datetimeapp.com/learn/common-timestamp-pitfalls)
- [Financial Data Timezone Mistakes](https://medium.com/@kevinmenesesgonzalez/5-common-mistakes-in-financial-data-extraction-and-how-to-fix-them-40eb8545764d)
- [Real-time vs Batch Data Tradeoffs](https://www.confluent.io/learn/batch-vs-real-time-data-processing/)
- [Crypto API Real-time Best Practices 2026](https://coinranking.com/blog/best-real-time-crypto-price-apis-in-2026-a-developer-guide/)

### Performance and Rendering
- [TradingView Performance Optimization](https://pineify.app/resources/blog/tradingview-running-slow-complete-guide-to-fix-lag-and-performance-issues)
- [TradingView Chart Troubleshooting](https://www.luxalgo.com/blog/ultimate-guide-to-tradingview-chart-troubleshooting/)

---

*Pitfalls research for: Influencer Call Tracking Platform*
*Researched: 2026-02-05*
