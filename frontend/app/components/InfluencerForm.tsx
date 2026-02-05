'use client'

import { useActionState } from 'react'
import type { Influencer, InfluencerActionState } from '@/app/lib/definitions'

interface InfluencerFormProps {
  action: (
    prevState: InfluencerActionState | null,
    formData: FormData
  ) => Promise<InfluencerActionState>
  influencer?: Influencer
  submitLabel: string
}

export default function InfluencerForm({
  action,
  influencer,
  submitLabel,
}: InfluencerFormProps) {
  const [state, formAction, pending] = useActionState(action, null)

  return (
    <form action={formAction} className="space-y-6">
      {state?.error && (
        <div className="bg-red-50 text-red-600 p-3 rounded-md text-sm">
          {state.error}
        </div>
      )}

      <div>
        <label
          htmlFor="name"
          className="block text-sm font-medium text-gray-700"
        >
          Name <span className="text-red-500">*</span>
        </label>
        <input
          id="name"
          name="name"
          type="text"
          required
          defaultValue={influencer?.name}
          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          placeholder="Enter influencer name"
        />
      </div>

      <div>
        <label
          htmlFor="avatar_url"
          className="block text-sm font-medium text-gray-700"
        >
          Avatar URL
        </label>
        <input
          id="avatar_url"
          name="avatar_url"
          type="url"
          defaultValue={influencer?.avatar_url || ''}
          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          placeholder="https://example.com/avatar.jpg"
        />
        <p className="mt-1 text-xs text-gray-500">
          URL to the influencer&apos;s profile picture
        </p>
      </div>

      <div>
        <label
          htmlFor="bio"
          className="block text-sm font-medium text-gray-700"
        >
          Bio
        </label>
        <textarea
          id="bio"
          name="bio"
          rows={4}
          defaultValue={influencer?.bio || ''}
          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          placeholder="Brief description of the influencer"
        />
        <p className="mt-1 text-xs text-gray-500">
          Maximum 1000 characters
        </p>
      </div>

      <div className="flex justify-end gap-3">
        <button
          type="submit"
          disabled={pending}
          className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {pending ? 'Saving...' : submitLabel}
        </button>
      </div>
    </form>
  )
}
