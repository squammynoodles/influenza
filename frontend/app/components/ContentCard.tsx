import { Content } from '@/app/lib/definitions'
import { getYoutubeThumbnail, getYoutubeUrl } from '@/app/lib/api'

interface ContentCardProps {
  content: Content
  twitterUsername?: string
}

export function ContentCard({ content, twitterUsername }: ContentCardProps) {
  const isVideo = content.type === 'YoutubeVideo'

  return (
    <div className="border rounded-lg p-4 hover:shadow-md transition-shadow bg-white">
      <div className="flex gap-4">
        {/* Thumbnail for videos */}
        {isVideo && (
          <div className="flex-shrink-0">
            <img
              src={getYoutubeThumbnail(content.external_id)}
              alt={content.title || 'Video thumbnail'}
              className="w-32 h-20 object-cover rounded"
            />
          </div>
        )}

        <div className="flex-1 min-w-0">
          {/* Type badge and date */}
          <div className="flex items-center gap-2 mb-1">
            <span
              className={`text-xs px-2 py-0.5 rounded ${
                isVideo ? 'bg-red-100 text-red-700' : 'bg-blue-100 text-blue-700'
              }`}
            >
              {isVideo ? 'YouTube' : 'Tweet'}
            </span>
            <span className="text-xs text-gray-500">
              {new Date(content.published_at).toLocaleDateString()}
            </span>
          </div>

          {/* Title/Text */}
          {isVideo ? (
            <h3 className="font-medium text-gray-900 truncate">{content.title}</h3>
          ) : (
            <p className="text-gray-900 line-clamp-3">{content.body}</p>
          )}

          {/* Transcript indicator for videos */}
          {isVideo && (
            <p className="text-xs text-gray-500 mt-1">
              {content.transcript ? 'Transcript available' : 'No transcript'}
            </p>
          )}

          {/* Link to source */}
          <a
            href={
              isVideo
                ? getYoutubeUrl(content.external_id)
                : `https://twitter.com/${twitterUsername || 'i'}/status/${content.external_id}`
            }
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-blue-600 hover:underline mt-2 inline-block"
          >
            View original
          </a>
        </div>
      </div>
    </div>
  )
}
