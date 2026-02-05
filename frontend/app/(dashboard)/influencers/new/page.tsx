import Link from 'next/link'
import { redirect } from 'next/navigation'
import { getUser } from '@/app/lib/dal'
import { createInfluencer } from '@/app/actions/influencers'
import InfluencerForm from '@/app/components/InfluencerForm'

export default async function NewInfluencerPage() {
  const user = await getUser()

  if (!user?.admin) {
    redirect('/influencers')
  }

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
          <h1 className="text-2xl font-bold text-gray-900">Add New Influencer</h1>
          <p className="mt-1 text-sm text-gray-600">
            Create a new influencer profile to start tracking their content.
          </p>
        </div>
        <div className="p-6">
          <InfluencerForm action={createInfluencer} submitLabel="Create Influencer" />
        </div>
      </div>
    </div>
  )
}
