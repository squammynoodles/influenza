import Link from 'next/link'
import { notFound } from 'next/navigation'
import { verifySession, getUser } from '@/app/lib/dal'
import { getInfluencer } from '@/app/lib/api'
import {
  deleteInfluencer,
  linkYoutubeChannel,
  linkTwitterAccount,
  unlinkYoutubeChannel,
  unlinkTwitterAccount,
} from '@/app/actions/influencers'
import LinkAccountForm from '@/app/components/LinkAccountForm'
import DeleteButton from './DeleteButton'
import UnlinkButton from './UnlinkButton'

interface PageProps {
  params: Promise<{ id: string }>
}

export default async function InfluencerDetailPage({ params }: PageProps) {
  const { id } = await params
  const influencerId = parseInt(id, 10)

  if (isNaN(influencerId)) {
    notFound()
  }

  const session = await verifySession()
  if (!session.isAuth) {
    return null
  }

  const user = await getUser()
  const isAdmin = user?.admin || false

  let influencer
  try {
    influencer = await getInfluencer(session.token, influencerId)
  } catch {
    notFound()
  }

  const deleteAction = deleteInfluencer.bind(null, influencerId)
  const linkYoutubeAction = linkYoutubeChannel.bind(null, influencerId)
  const linkTwitterAction = linkTwitterAccount.bind(null, influencerId)

  return (
    <div>
      <div className="mb-6">
        <Link
          href="/influencers"
          className="text-sm text-indigo-600 hover:text-indigo-500 flex items-center gap-1"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to Influencers
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-start justify-between">
            <div className="flex items-start gap-6">
              {influencer.avatar_url ? (
                <img
                  src={influencer.avatar_url}
                  alt={influencer.name}
                  className="w-24 h-24 rounded-full object-cover"
                />
              ) : (
                <div className="w-24 h-24 rounded-full bg-gray-200 flex items-center justify-center">
                  <span className="text-4xl font-medium text-gray-500">
                    {influencer.name.charAt(0).toUpperCase()}
                  </span>
                </div>
              )}
              <div>
                <h1 className="text-2xl font-bold text-gray-900">{influencer.name}</h1>
                {influencer.bio && (
                  <p className="mt-2 text-gray-600 max-w-2xl">{influencer.bio}</p>
                )}
                <Link
                  href={`/influencers/${influencer.id}/content`}
                  className="inline-flex items-center gap-1 mt-3 text-sm text-indigo-600 hover:text-indigo-500"
                >
                  View Content History
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </Link>
              </div>
            </div>
            {isAdmin && (
              <div className="flex gap-3">
                <Link
                  href={`/influencers/${influencer.id}/edit`}
                  className="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
                >
                  Edit
                </Link>
                <DeleteButton action={deleteAction} influencerName={influencer.name} />
              </div>
            )}
          </div>
        </div>

        {/* YouTube Channels Section */}
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-center gap-2 mb-4">
            <svg className="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 24 24">
              <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
            </svg>
            <h2 className="text-lg font-semibold text-gray-900">YouTube Channels</h2>
          </div>

          {influencer.youtube_channels && influencer.youtube_channels.length > 0 ? (
            <div className="space-y-3 mb-4">
              {influencer.youtube_channels.map((channel) => (
                <div
                  key={channel.id}
                  className="flex items-center justify-between p-3 bg-gray-50 rounded-md"
                >
                  <div className="flex items-center gap-3">
                    {channel.thumbnail_url ? (
                      <img
                        src={channel.thumbnail_url}
                        alt={channel.title || channel.channel_id}
                        className="w-10 h-10 rounded-full"
                      />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center">
                        <svg className="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
                        </svg>
                      </div>
                    )}
                    <div>
                      <p className="font-medium text-gray-900">
                        {channel.title || channel.channel_id}
                      </p>
                      <p className="text-sm text-gray-500">{channel.channel_id}</p>
                    </div>
                  </div>
                  {isAdmin && (
                    <UnlinkButton
                      action={unlinkYoutubeChannel.bind(null, influencerId, channel.id)}
                      type="channel"
                    />
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-gray-500 mb-4">No YouTube channels linked yet.</p>
          )}

          {isAdmin && (
            <div className="pt-4 border-t border-gray-200">
              <h3 className="text-sm font-medium text-gray-700 mb-3">Link YouTube Channel</h3>
              <LinkAccountForm action={linkYoutubeAction} type="youtube" />
            </div>
          )}
        </div>

        {/* Twitter Accounts Section */}
        <div className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <svg className="w-5 h-5 text-blue-400" fill="currentColor" viewBox="0 0 24 24">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
            </svg>
            <h2 className="text-lg font-semibold text-gray-900">Twitter Accounts</h2>
          </div>

          {influencer.twitter_accounts && influencer.twitter_accounts.length > 0 ? (
            <div className="space-y-3 mb-4">
              {influencer.twitter_accounts.map((account) => (
                <div
                  key={account.id}
                  className="flex items-center justify-between p-3 bg-gray-50 rounded-md"
                >
                  <div className="flex items-center gap-3">
                    {account.profile_image_url ? (
                      <img
                        src={account.profile_image_url}
                        alt={account.display_name || account.username}
                        className="w-10 h-10 rounded-full"
                      />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                        <svg className="w-5 h-5 text-blue-400" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                        </svg>
                      </div>
                    )}
                    <div>
                      <p className="font-medium text-gray-900">
                        {account.display_name || account.username}
                      </p>
                      <p className="text-sm text-gray-500">@{account.username}</p>
                    </div>
                  </div>
                  {isAdmin && (
                    <UnlinkButton
                      action={unlinkTwitterAccount.bind(null, influencerId, account.id)}
                      type="account"
                    />
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-gray-500 mb-4">No Twitter accounts linked yet.</p>
          )}

          {isAdmin && (
            <div className="pt-4 border-t border-gray-200">
              <h3 className="text-sm font-medium text-gray-700 mb-3">Link Twitter Account</h3>
              <LinkAccountForm action={linkTwitterAction} type="twitter" />
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
