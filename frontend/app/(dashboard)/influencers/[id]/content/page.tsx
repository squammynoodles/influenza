import { Suspense } from 'react'
import Link from 'next/link'
import { redirect, notFound } from 'next/navigation'
import { verifySession } from '@/app/lib/dal'
import { getInfluencer, getInfluencerContents } from '@/app/lib/api'
import { ContentList } from '@/app/components/ContentList'
import { ContentFilters } from '@/app/components/ContentFilters'

interface PageProps {
  params: Promise<{ id: string }>
  searchParams: Promise<{ type?: string; page?: string }>
}

export default async function InfluencerContentPage({
  params,
  searchParams,
}: PageProps) {
  const session = await verifySession()
  if (!session.isAuth) redirect('/login')

  const { id } = await params
  const { type, page } = await searchParams

  const influencerId = parseInt(id, 10)
  if (isNaN(influencerId)) {
    notFound()
  }

  const currentPage = parseInt(page || '1', 10)
  const perPage = 20

  let influencer
  let contentsResponse

  try {
    ;[influencer, contentsResponse] = await Promise.all([
      getInfluencer(session.token, influencerId),
      getInfluencerContents(session.token, influencerId, {
        type: type as 'youtube_video' | 'tweet' | undefined,
        page: currentPage,
        per_page: perPage,
      }),
    ])
  } catch {
    notFound()
  }

  const { contents, meta } = contentsResponse

  // Get twitter username for tweet URLs
  const twitterUsername = influencer.twitter_accounts?.[0]?.username

  const totalPages = Math.ceil(meta.total / meta.per_page)
  const baseUrl = `/influencers/${id}/content`

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <Link
          href={`/influencers/${id}`}
          className="text-sm text-blue-600 hover:underline"
        >
          &larr; Back to {influencer.name}
        </Link>
        <h1 className="text-2xl font-bold mt-2">Content History</h1>
        <p className="text-gray-600">
          {meta.total} items from {influencer.name}
        </p>
      </div>

      {/* Filters */}
      <Suspense fallback={<div className="h-8" />}>
        <ContentFilters baseUrl={baseUrl} />
      </Suspense>

      {/* Content list */}
      <ContentList
        contents={contents}
        twitterUsername={twitterUsername}
        emptyMessage="No content has been synced yet. Content will appear here after the next hourly sync."
      />

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center gap-2 mt-8">
          {currentPage > 1 && (
            <Link
              href={`${baseUrl}?${new URLSearchParams({
                ...(type && { type }),
                page: (currentPage - 1).toString(),
              })}`}
              className="px-4 py-2 bg-gray-100 rounded hover:bg-gray-200"
            >
              Previous
            </Link>
          )}

          <span className="px-4 py-2 text-gray-600">
            Page {currentPage} of {totalPages}
          </span>

          {currentPage < totalPages && (
            <Link
              href={`${baseUrl}?${new URLSearchParams({
                ...(type && { type }),
                page: (currentPage + 1).toString(),
              })}`}
              className="px-4 py-2 bg-gray-100 rounded hover:bg-gray-200"
            >
              Next
            </Link>
          )}
        </div>
      )}
    </div>
  )
}
