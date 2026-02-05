# Phase 2: Influencer & Content Pipeline - Research

**Researched:** 2026-02-06
**Domain:** Social Media API Integration, Background Job Processing, Content Aggregation
**Confidence:** MEDIUM (API landscape is volatile; transcript extraction uses unofficial methods)

## Summary

This phase requires integrating YouTube and Twitter/X APIs to pull content from tracked influencers. The research reveals a complex API landscape with significant cost and access constraints.

**YouTube**: The official Data API v3 is well-suited for channel/video metadata (1 quota unit per call, 10K daily quota). However, **transcript extraction via official API requires OAuth with video owner permission** (50-200 quota units per call), making it unusable for third-party content. The recommended approach is the Innertube-based scraping method used by popular libraries - no API key required, works for any public video with captions.

**Twitter/X**: The official API has become prohibitively expensive for read operations. The Free tier ($0) allows **zero reads** (write-only). Basic tier ($200/month) allows only 15K tweet reads/month. A third-party service like TwitterAPI.io ($0.15 per 1K tweets) is the pragmatic choice for this use case.

**Background Jobs**: Rails 8's Solid Queue with `recurring.yml` handles the hourly batch processing requirement natively - no additional gems needed.

**Primary recommendation:** Use YouTube Data API v3 for channel/video metadata, implement Innertube-based transcript scraping in Ruby, and use TwitterAPI.io (or similar third-party service) for tweet ingestion.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| google-apis-youtube_v3 | latest | YouTube channel/video metadata | Official Google Ruby SDK, well-maintained |
| httparty or faraday | 0.23+ / 2.x | HTTP client for API calls | Standard Rails HTTP clients |
| solid_queue | built-in | Background job processing | Rails 8 default, no Redis needed |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| nokogiri | 1.15+ | XML parsing for transcript data | Parsing Innertube transcript XML |
| addressable | 2.8+ | URL encoding/parsing | Handling YouTube URLs with special chars |

### Not Using (Decided Against)
| Library | Reason |
|---------|--------|
| youtube_transcript2020 gem | Last updated 2022, unmaintained, likely broken |
| sidekiq | Requires Redis; Solid Queue works with PostgreSQL |
| Official Twitter API | $200+/month for read access; Free tier is write-only |

**Installation:**
```bash
cd api
bundle add google-apis-youtube_v3
bundle add httparty  # or faraday if preferred
# nokogiri is already a Rails dependency
```

## Architecture Patterns

### Recommended Data Model Structure

```
influencers
├── id, name, avatar_url, bio
├── created_at, updated_at
└── (avatar stored as URL string, not ActiveStorage)

youtube_channels
├── id, influencer_id, channel_id (YouTube's ID)
├── title, description, thumbnail_url
├── uploads_playlist_id (for fetching videos)
├── last_synced_at
└── created_at, updated_at

twitter_accounts
├── id, influencer_id, username
├── display_name, profile_image_url, bio
├── last_synced_at
└── created_at, updated_at

contents (polymorphic or STI)
├── id, influencer_id
├── type (YoutubeVideo, Tweet)
├── external_id (video_id or tweet_id)
├── title, body/text
├── transcript (for videos)
├── published_at
├── metadata (JSONB for extra fields)
├── created_at, updated_at
└── indexes on [influencer_id, published_at], [external_id, type]
```

### Pattern 1: STI for Content Types (Recommended)

**What:** Single Table Inheritance for YouTubeVideo and Tweet content
**When to use:** When content types share most attributes (external_id, influencer, published_at, text/body)
**Why:** Simpler queries ("get all content for influencer"), single index, DRY code

```ruby
# app/models/content.rb
class Content < ApplicationRecord
  belongs_to :influencer

  scope :recent, -> { order(published_at: :desc) }
  scope :videos, -> { where(type: 'YoutubeVideo') }
  scope :tweets, -> { where(type: 'Tweet') }
end

# app/models/youtube_video.rb
class YoutubeVideo < Content
  validates :transcript, presence: true, on: :update

  def thumbnail_url
    "https://img.youtube.com/vi/#{external_id}/mqdefault.jpg"
  end
end

# app/models/tweet.rb
class Tweet < Content
  # Twitter-specific behavior
end
```

### Pattern 2: Service Objects for API Ingestion

**What:** Dedicated service classes for each API integration
**When to use:** Always - keeps controllers thin, business logic testable

```ruby
# app/services/youtube/channel_sync_service.rb
module Youtube
  class ChannelSyncService
    def initialize(youtube_channel)
      @channel = youtube_channel
    end

    def call
      videos = fetch_recent_videos
      videos.each do |video_data|
        sync_video(video_data)
      end
      @channel.touch(:last_synced_at)
    end

    private

    def fetch_recent_videos
      # Use google-apis-youtube_v3 to get playlist items
    end

    def sync_video(data)
      video = YoutubeVideo.find_or_initialize_by(external_id: data.id)
      # Update attributes, fetch transcript if new
    end
  end
end

# app/services/youtube/transcript_fetcher.rb
module Youtube
  class TranscriptFetcher
    INNERTUBE_URL = "https://www.youtube.com/youtubei/v1/get_transcript"

    def fetch(video_id)
      # 1. Fetch video page to get params
      # 2. Call Innertube endpoint
      # 3. Parse XML response
    end
  end
end
```

### Pattern 3: Recurring Jobs with Solid Queue

**What:** Hourly batch jobs defined in `config/recurring.yml`
**When to use:** For the scheduled ingestion requirement

```yaml
# config/recurring.yml
production:
  sync_youtube_channels:
    class: SyncYoutubeChannelsJob
    schedule: every hour at minute 0
    queue: ingestion

  sync_twitter_accounts:
    class: SyncTwitterAccountsJob
    schedule: every hour at minute 30
    queue: ingestion

  clear_solid_queue_finished_jobs:
    command: "SolidQueue::Job.clear_finished_in_batches(sleep_between_batches: 0.3)"
    schedule: every hour at minute 12

development:
  # Same jobs but can run more frequently for testing
  sync_youtube_channels:
    class: SyncYoutubeChannelsJob
    schedule: every 5 minutes
```

### Anti-Patterns to Avoid

- **Fat controllers:** Don't put API calls in controllers. Use service objects.
- **N+1 in batch jobs:** Use `find_each` and preload associations.
- **Storing transcripts without compression:** Transcripts can be large; consider text compression or external storage for videos with transcripts >100KB.
- **Synchronous API calls in web requests:** All external API calls belong in background jobs.
- **Hardcoded API keys:** Use Rails credentials or environment variables.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YouTube video metadata | Custom scraper | google-apis-youtube_v3 | Handles auth, pagination, rate limiting |
| Cron-like scheduling | Custom scheduler table | Solid Queue recurring.yml | Built into Rails 8, battle-tested |
| HTTP requests with retries | Raw Net::HTTP | HTTParty/Faraday with retry middleware | Handles timeouts, retries, encoding |
| URL validation | Regex patterns | Addressable::URI | Edge cases with encoding, unicode |

**Key insight:** YouTube's official API is excellent for metadata but useless for third-party transcripts. The Innertube scraping approach is unavoidable but well-documented across multiple language implementations.

## Common Pitfalls

### Pitfall 1: YouTube API Quota Exhaustion
**What goes wrong:** Hitting 10K daily quota limit, ingestion stops
**Why it happens:** Inefficient polling, fetching full video details unnecessarily
**How to avoid:**
- Use playlistItems.list (1 unit) to check for new videos by date
- Only fetch video details for genuinely new content
- Cache channel metadata (uploads_playlist_id)
- With 10 influencers, hourly polling = 240 calls/day for listings (2.4% of quota)
**Warning signs:** Monitor quota usage in Google Cloud Console

### Pitfall 2: Innertube API Breaking Changes
**What goes wrong:** Transcript fetching stops working suddenly
**Why it happens:** YouTube changes internal API without notice
**How to avoid:**
- Implement robust error handling
- Log failures with video IDs for retry
- Have fallback (mark video as "transcript pending")
- Monitor the youtube-transcript-api Python repo for reported issues
**Warning signs:** Sudden spike in transcript fetch failures

### Pitfall 3: Twitter Rate Limits / Service Changes
**What goes wrong:** Third-party service becomes unavailable or expensive
**Why it happens:** Twitter aggressively restricts access, services shut down
**How to avoid:**
- Abstract Twitter integration behind interface
- Store raw API responses for reprocessing
- Have a plan B service (Apify, direct scraping)
- Start with TwitterAPI.io but monitor costs
**Warning signs:** HTTP 429 errors, changed pricing emails

### Pitfall 4: Job Processing Bottlenecks
**What goes wrong:** Jobs back up, content becomes stale
**Why it happens:** Single job processes all influencers sequentially
**How to avoid:**
- Master job spawns individual channel/account jobs
- Use concurrency controls in Solid Queue
- Stagger job start times (YouTube at :00, Twitter at :30)
**Warning signs:** Growing job queue, last_synced_at timestamps drifting

### Pitfall 5: Duplicate Content
**What goes wrong:** Same video/tweet inserted multiple times
**Why it happens:** Race conditions, job retries without idempotency
**How to avoid:**
- Unique index on [external_id, type] for contents table
- Use `find_or_create_by` with proper constraints
- Make jobs idempotent (re-running produces same result)
**Warning signs:** Database constraint violations in logs

## Code Examples

### YouTube Channel Video Listing (Official API)
```ruby
# Source: google-apis-youtube_v3 gem documentation
require 'google/apis/youtube_v3'

class Youtube::VideoListService
  def initialize(api_key)
    @service = Google::Apis::YoutubeV3::YouTubeService.new
    @service.key = api_key
  end

  def recent_videos(playlist_id, published_after: 1.day.ago)
    items = []
    page_token = nil

    loop do
      response = @service.list_playlist_items(
        'snippet,contentDetails',
        playlist_id: playlist_id,
        max_results: 50,
        page_token: page_token
      )

      response.items.each do |item|
        published_at = Time.parse(item.content_details.video_published_at)
        break if published_at < published_after
        items << {
          video_id: item.content_details.video_id,
          title: item.snippet.title,
          description: item.snippet.description,
          published_at: published_at,
          thumbnail_url: item.snippet.thumbnails&.medium&.url
        }
      end

      page_token = response.next_page_token
      break unless page_token
    end

    items
  end
end
```

### YouTube Transcript Fetching (Innertube Scraping)
```ruby
# Based on: youtube-transcript-api Python implementation
# Source: https://github.com/jdepoix/youtube-transcript-api

class Youtube::TranscriptFetcher
  WATCH_URL = "https://www.youtube.com/watch?v=%s"

  def fetch(video_id)
    # Step 1: Get video page to extract transcript params
    page_html = HTTParty.get(WATCH_URL % video_id).body

    # Step 2: Extract captions data from page
    captions_json = extract_captions_json(page_html)
    return nil unless captions_json

    # Step 3: Find English transcript URL
    caption_track = find_english_track(captions_json)
    return nil unless caption_track

    # Step 4: Fetch and parse transcript XML
    transcript_xml = HTTParty.get(caption_track['baseUrl']).body
    parse_transcript_xml(transcript_xml)
  end

  private

  def extract_captions_json(html)
    # Look for playerCaptionsTracklistRenderer in page data
    match = html.match(/"captions":\s*(\{[^}]+playerCaptionsTracklistRenderer[^}]+\})/)
    return nil unless match
    JSON.parse(match[1])['playerCaptionsTracklistRenderer']
  rescue JSON::ParserError
    nil
  end

  def find_english_track(captions)
    tracks = captions['captionTracks'] || []
    tracks.find { |t| t['languageCode'] == 'en' } ||
    tracks.find { |t| t['languageCode'].start_with?('en') } ||
    tracks.first  # Fallback to any available
  end

  def parse_transcript_xml(xml)
    doc = Nokogiri::XML(xml)
    segments = doc.css('text').map do |node|
      {
        text: CGI.unescapeHTML(node.text),
        start: node['start'].to_f,
        duration: node['dur']&.to_f || 0.0
      }
    end

    # Join into full transcript text
    segments.map { |s| s[:text] }.join(' ')
  end
end
```

### TwitterAPI.io Integration
```ruby
# Source: https://twitterapi.io/readme

class Twitter::TweetFetcher
  BASE_URL = "https://api.twitterapi.io/twitter"

  def initialize(api_key)
    @api_key = api_key
  end

  def recent_tweets(username, since: 1.day.ago)
    response = HTTParty.get(
      "#{BASE_URL}/user/last_tweets",
      headers: { 'X-API-Key' => @api_key },
      query: { userName: username }
    )

    return [] unless response.success?

    tweets = JSON.parse(response.body)['tweets'] || []
    tweets.select do |tweet|
      Time.parse(tweet['created_at']) > since
    end.map do |tweet|
      {
        tweet_id: tweet['id'],
        text: tweet['text'],
        published_at: Time.parse(tweet['created_at']),
        metadata: {
          retweet_count: tweet['retweet_count'],
          like_count: tweet['like_count']
        }
      }
    end
  rescue JSON::ParserError
    []
  end
end
```

### Recurring Job Setup
```ruby
# app/jobs/sync_youtube_channels_job.rb
class SyncYoutubeChannelsJob < ApplicationJob
  queue_as :ingestion

  def perform
    YoutubeChannel.find_each do |channel|
      SyncSingleYoutubeChannelJob.perform_later(channel.id)
    end
  end
end

# app/jobs/sync_single_youtube_channel_job.rb
class SyncSingleYoutubeChannelJob < ApplicationJob
  queue_as :ingestion
  limits_concurrency to: 5, key: :youtube_sync  # Solid Queue feature

  def perform(channel_id)
    channel = YoutubeChannel.find(channel_id)
    Youtube::ChannelSyncService.new(channel).call
  rescue => e
    Rails.logger.error("YouTube sync failed for channel #{channel_id}: #{e.message}")
    raise  # Re-raise for retry
  end
end
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Twitter API v1.1 free tier | v2 paid tiers only | 2023 | Third-party services now necessary for affordable read access |
| youtube-dl for transcripts | yt-dlp / Innertube direct | 2021+ | youtube-dl less maintained, yt-dlp is active fork |
| Sidekiq for Rails jobs | Solid Queue (Rails 8 default) | 2024 | No Redis needed, simpler deployment |
| google-api-client gem | google-apis-youtube_v3 gem | 2021 | Newer modular gem, better maintained |

**Deprecated/outdated:**
- Twitter API Free tier for reading: Gone as of 2023, now write-only
- youtube_transcript2020 gem: Last update 2022, likely broken
- Relying on Nitter: Intermittent availability, not production-ready

## Open Questions

Things that couldn't be fully resolved:

1. **TwitterAPI.io reliability long-term**
   - What we know: $0.15/1K tweets, $1 free credit, API works
   - What's unclear: Long-term viability, ToS compliance with Twitter
   - Recommendation: Start with it, abstract behind interface, have Apify as backup

2. **Innertube transcript stability**
   - What we know: Works as of 2025, used by major libraries
   - What's unclear: How frequently YouTube changes it
   - Recommendation: Implement with good error handling, monitor youtube-transcript-api issues

3. **Optimal batch frequency for quota**
   - What we know: 10K quota/day, hourly specified in requirements
   - What's unclear: Whether 15-30 min intervals are better for freshness
   - Recommendation: Start with hourly as specified; can adjust if users need fresher data

4. **Avatar storage approach**
   - What we know: Can use ActiveStorage or simple URL string
   - What's unclear: Whether we need to cache avatars locally
   - Recommendation: Store as URL string (avatar_url), simpler and avatars are hosted by YouTube/Twitter

## API Cost Analysis

### YouTube Data API v3 (10K units/day free)

| Operation | Quota Cost | Usage Pattern | Daily Cost |
|-----------|------------|---------------|------------|
| playlistItems.list | 1 | 10 channels x 24 hours | 240 units |
| videos.list | 1 | ~50 new videos/day | 50 units |
| channels.list | 1 | Initial setup only | ~10 units |
| **Total estimated** | | | **~300 units/day** |

**Conclusion:** 3% of daily quota used. Plenty of headroom for growth.

### TwitterAPI.io

| Operation | Cost | Usage Pattern | Monthly Cost |
|-----------|------|---------------|--------------|
| Tweets fetch | $0.15/1K | 10 accounts x 30 tweets x 30 days | ~$1.35 |
| User profiles | $0.18/1K | 10 accounts x 30 days | ~$0.05 |
| **Total estimated** | | | **~$2/month** |

**Conclusion:** Extremely affordable for this scale. The $1 free credit covers initial testing.

## Sources

### Primary (HIGH confidence)
- [YouTube Data API Quota Calculator](https://developers.google.com/youtube/v3/determine_quota_cost) - Verified quota costs
- [YouTube Data API Ruby Quickstart](https://developers.google.com/youtube/v3/quickstart/ruby) - Official Ruby integration
- [Captions Download Requirements](https://developers.google.com/youtube/v3/docs/captions/download) - OAuth requirement verified
- [Solid Queue GitHub](https://github.com/rails/solid_queue) - Recurring jobs configuration
- [Solid Queue Rails Guide](https://nsinenko.com/rails/background-jobs/performance/2025/10/07/solid-queue-rails-practical-guide/) - recurring.yml format

### Secondary (MEDIUM confidence)
- [TwitterAPI.io Documentation](https://twitterapi.io/readme) - Third-party service, verified pricing
- [X/Twitter API Pricing Guide](https://getlate.dev/blog/twitter-api-pricing) - Current tier structure
- [youtube-transcript-api Python](https://github.com/jdepoix/youtube-transcript-api) - Innertube approach reference

### Tertiary (LOW confidence)
- [Apify Twitter Pricing](https://apify.com/pricing) - Alternative service, pricing varies
- youtube_transcript2020 gem - Unmaintained, not recommended

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Using official Google SDK, proven Rails 8 patterns
- Architecture: HIGH - Standard Rails patterns, well-documented
- YouTube API costs: HIGH - Official documentation verified
- Twitter integration: MEDIUM - Third-party service, may change
- Transcript extraction: MEDIUM - Unofficial API, works but fragile
- Pitfalls: MEDIUM - Based on community experience, not first-hand

**Research date:** 2026-02-06
**Valid until:** 2026-03-06 (30 days - Twitter landscape especially volatile)
