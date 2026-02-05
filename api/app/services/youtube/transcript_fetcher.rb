# frozen_string_literal: true

require "open3"
require "tmpdir"

module Youtube
  class TranscriptFetcher
    class TranscriptNotAvailable < StandardError; end

    def fetch(video_id)
      Dir.mktmpdir do |dir|
        cmd = [
          "yt-dlp",
          "--skip-download",
          "--write-auto-sub",
          "--write-sub",
          "--sub-lang", "en",
          "--sub-format", "vtt",
          "--output", "#{dir}/%(id)s",
          "https://www.youtube.com/watch?v=#{video_id}"
        ]

        _stdout, stderr, status = Open3.capture3(*cmd)

        unless status.success?
          raise TranscriptNotAvailable, "yt-dlp subtitle extraction failed for #{video_id}: #{stderr.strip}"
        end

        sub_file = Dir.glob("#{dir}/*.vtt").first
        raise TranscriptNotAvailable, "No subtitles found for video #{video_id}" unless sub_file

        parse_vtt(File.read(sub_file))
      end
    end

    private

    def parse_vtt(vtt_content)
      lines = vtt_content.lines.map(&:strip)

      # Skip header (WEBVTT and any metadata lines before first blank line)
      in_header = true
      text_lines = []

      lines.each do |line|
        if in_header
          in_header = false if line.empty?
          next
        end

        # Skip timestamp lines (e.g., "00:00:01.000 --> 00:00:04.000")
        next if line.match?(/\A\d{2}:\d{2}:\d{2}\.\d{3}\s*-->/)
        # Skip cue index lines (numeric only)
        next if line.match?(/\A\d+\z/)
        # Skip empty lines
        next if line.empty?

        # Strip VTT formatting tags like <c>, </c>, <00:00:01.234>, etc.
        clean = line.gsub(/<[^>]+>/, "")
        text_lines << clean unless clean.empty?
      end

      # Deduplicate consecutive identical lines (common in auto-generated subs)
      deduped = text_lines.chunk_while { |a, b| a == b }.map(&:first)

      deduped.join(" ").gsub(/\s+/, " ").strip
    end
  end
end
