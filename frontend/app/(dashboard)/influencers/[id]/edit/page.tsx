import Link from 'next/link'
import { redirect, notFound } from 'next/navigation'
import { verifySession, getUser } from '@/app/lib/dal'
import { getInfluencer } from '@/app/lib/api'
import { updateInfluencer } from '@/app/actions/influencers'
import InfluencerForm from '@/app/components/InfluencerForm'

interface PageProps {
  params: Promise<{ id: string }>
}

export default async function EditInfluencerPage({ params }: PageProps) {
  const { id } = await params
  const influencerId = parseInt(id, 10)

  if (isNaN(influencerId)) {
    notFound()
  }

  const user = await getUser()
  if (!user?.admin) {
    redirect('/influencers')
  }

  const session = await verifySession()
  if (!session.isAuth) {
    redirect('/login')
  }

  let influencer
  try {
    influencer = await getInfluencer(session.token, influencerId)
  } catch {
    notFound()
  }

  const updateAction = updateInfluencer.bind(null, influencerId)

  return (
    <div>
      <div className="mb-6">
        <Link
          href={`/influencers/${influencer.id}`}
          className="text-sm text-indigo-600 hover:text-indigo-500 flex items-center gap-1"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to {influencer.name}
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b border-gray-200">
          <h1 className="text-2xl font-bold text-gray-900">Edit Influencer</h1>
          <p className="mt-1 text-sm text-gray-600">
            Update the profile information for {influencer.name}.
          </p>
        </div>
        <div className="p-6">
          <InfluencerForm
            action={updateAction}
            influencer={influencer}
            submitLabel="Save Changes"
          />
        </div>
      </div>
    </div>
  )
}
