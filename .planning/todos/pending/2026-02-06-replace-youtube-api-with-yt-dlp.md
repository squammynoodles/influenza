---
created: 2026-02-06T12:00
title: Replace YouTube Data API with yt-dlp
area: api
files:
  - api/app/services/youtube/video_list_service.rb
  - api/app/services/youtube/transcript_fetcher.rb
  - api/app/models/youtube_channel.rb
---

## Problem

The current YouTube ingestion pipeline uses two separate approaches:
- **VideoListService** uses the `google-apis-youtube_v3` gem which requires a `YOUTUBE_API_KEY` (paid API with quota limits)
- **TranscriptFetcher** scrapes YouTube page HTML for captions (Innertube approach, fragile regex parsing)

This means a YouTube API key is still required for video listing, adding cost and a dependency that could be eliminated. The HTML scraping for transcripts is also brittle and may break when YouTube changes their page structure.

`yt-dlp` is already available on the system (Python 3.14.2 installed) and can handle both video listing and subtitle extraction without any API key, eliminating the YouTube API dependency entirely.

## Solution

Replace both services with yt-dlp shell calls:
- `yt-dlp --flat-playlist --dump-json <channel_url>` for video listing
- `yt-dlp --write-auto-sub --sub-lang en --skip-download --print-json <video_url>` for transcript extraction
- Remove `google-apis-youtube_v3` gem from Gemfile
- Remove `YOUTUBE_API_KEY` env var requirement
- May simplify youtube_channel model (no longer needs `uploads_playlist_id`)
