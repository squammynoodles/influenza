import Link from 'next/link'
import type { Influencer } from '@/app/lib/definitions'

interface InfluencerCardProps {
  influencer: Influencer
}

export default function InfluencerCard({ influencer }: InfluencerCardProps) {
  const youtubeCount = influencer.youtube_channels?.length || 0
  const twitterCount = influencer.twitter_accounts?.length || 0

  return (
    <Link
      href={`/influencers/${influencer.id}`}
      className="block bg-white rounded-lg shadow hover:shadow-md transition-shadow"
    >
      <div className="p-6">
        <div className="flex items-start gap-4">
          {influencer.avatar_url ? (
            <img
              src={influencer.avatar_url}
              alt={influencer.name}
              className="w-16 h-16 rounded-full object-cover"
            />
          ) : (
            <div className="w-16 h-16 rounded-full bg-gray-200 flex items-center justify-center">
              <span className="text-2xl font-medium text-gray-500">
                {influencer.name.charAt(0).toUpperCase()}
              </span>
            </div>
          )}
          <div className="flex-1 min-w-0">
            <h3 className="text-lg font-semibold text-gray-900 truncate">
              {influencer.name}
            </h3>
            {influencer.bio && (
              <p className="mt-1 text-sm text-gray-600 line-clamp-2">
                {influencer.bio}
              </p>
            )}
            <div className="mt-3 flex gap-4">
              <span className="inline-flex items-center text-xs text-gray-500">
                <svg
                  className="w-4 h-4 mr-1 text-red-500"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
                </svg>
                {youtubeCount} channel{youtubeCount !== 1 ? 's' : ''}
              </span>
              <span className="inline-flex items-center text-xs text-gray-500">
                <svg
                  className="w-4 h-4 mr-1 text-blue-400"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                </svg>
                {twitterCount} account{twitterCount !== 1 ? 's' : ''}
              </span>
            </div>
          </div>
        </div>
      </div>
    </Link>
  )
}
