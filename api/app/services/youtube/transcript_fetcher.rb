# frozen_string_literal: true

require "httparty"
require "nokogiri"
require "cgi"

module Youtube
  class TranscriptFetcher
    WATCH_URL = "https://www.youtube.com/watch?v=%s"

    class TranscriptNotAvailable < StandardError; end

    def fetch(video_id)
      # Step 1: Get video page to extract transcript params
      page_html = HTTParty.get(WATCH_URL % video_id, timeout: 10).body

      # Step 2: Extract captions data from page
      captions_json = extract_captions_json(page_html)
      raise TranscriptNotAvailable, "No captions found for video #{video_id}" unless captions_json

      # Step 3: Find English transcript URL
      caption_track = find_english_track(captions_json)
      raise TranscriptNotAvailable, "No English captions for video #{video_id}" unless caption_track

      # Step 4: Fetch and parse transcript XML
      transcript_xml = HTTParty.get(caption_track["baseUrl"], timeout: 10).body
      parse_transcript_xml(transcript_xml)
    rescue HTTParty::Error, Timeout::Error => e
      raise TranscriptNotAvailable, "Network error fetching transcript: #{e.message}"
    end

    private

    def extract_captions_json(html)
      # Look for playerCaptionsTracklistRenderer in page data
      # The captions JSON is embedded in the initial player response
      match = html.match(/"captions":\s*(\{"playerCaptionsTracklistRenderer"[^}]+\})\s*,\s*"videoDetails"/)

      if match
        begin
          json_str = match[1]
          # Fix JSON by ensuring it's properly closed
          json_str = balance_braces(json_str)
          parsed = JSON.parse(json_str)
          return parsed["playerCaptionsTracklistRenderer"]
        rescue JSON::ParserError
          # Try alternative extraction
        end
      end

      # Alternative: look for captionTracks directly
      tracks_match = html.match(/"captionTracks":\s*(\[[^\]]+\])/)
      if tracks_match
        begin
          tracks = JSON.parse(tracks_match[1])
          return { "captionTracks" => tracks }
        rescue JSON::ParserError
          nil
        end
      end

      nil
    end

    def balance_braces(str)
      # Simple brace balancing for truncated JSON
      open_count = str.count("{") - str.count("}")
      str + ("}" * [ open_count, 0 ].max)
    end

    def find_english_track(captions)
      tracks = captions["captionTracks"] || []
      tracks.find { |t| t["languageCode"] == "en" } ||
        tracks.find { |t| t["languageCode"]&.start_with?("en") } ||
        tracks.first  # Fallback to any available
    end

    def parse_transcript_xml(xml)
      doc = Nokogiri::XML(xml)
      segments = doc.css("text").map do |node|
        CGI.unescapeHTML(node.text.to_s)
      end

      # Join into full transcript text
      segments.join(" ").gsub(/\s+/, " ").strip
    end
  end
end
