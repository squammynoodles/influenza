class YoutubeVideo < Content
  def thumbnail_url
    "https://img.youtube.com/vi/#{external_id}/mqdefault.jpg"
  end
end
