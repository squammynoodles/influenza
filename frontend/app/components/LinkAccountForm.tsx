'use client'

import { useActionState } from 'react'
import type { InfluencerActionState } from '@/app/lib/definitions'

interface LinkAccountFormProps {
  action: (
    prevState: InfluencerActionState | null,
    formData: FormData
  ) => Promise<InfluencerActionState>
  type: 'youtube' | 'twitter'
}

export default function LinkAccountForm({ action, type }: LinkAccountFormProps) {
  const [state, formAction, pending] = useActionState(action, null)

  if (type === 'youtube') {
    return (
      <form action={formAction} className="space-y-3">
        {state?.error && (
          <div className="bg-red-50 text-red-600 p-2 rounded-md text-sm">
            {state.error}
          </div>
        )}
        {state?.success && (
          <div className="bg-green-50 text-green-600 p-2 rounded-md text-sm">
            YouTube channel linked successfully!
          </div>
        )}

        <div className="flex gap-2">
          <div className="flex-1">
            <input
              name="channel_id"
              type="text"
              required
              className="block w-full px-3 py-2 text-sm border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              placeholder="Channel ID (e.g., UC...)"
            />
          </div>
          <button
            type="submit"
            disabled={pending}
            className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50"
          >
            {pending ? 'Linking...' : 'Link Channel'}
          </button>
        </div>
        <p className="text-xs text-gray-500">
          Find the channel ID in the YouTube channel URL or about page
        </p>
      </form>
    )
  }

  return (
    <form action={formAction} className="space-y-3">
      {state?.error && (
        <div className="bg-red-50 text-red-600 p-2 rounded-md text-sm">
          {state.error}
        </div>
      )}
      {state?.success && (
        <div className="bg-green-50 text-green-600 p-2 rounded-md text-sm">
          Twitter account linked successfully!
        </div>
      )}

      <div className="flex gap-2">
        <div className="flex-1">
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400">
              @
            </span>
            <input
              name="username"
              type="text"
              required
              className="block w-full pl-7 pr-3 py-2 text-sm border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              placeholder="username"
            />
          </div>
        </div>
        <button
          type="submit"
          disabled={pending}
          className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-500 hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
        >
          {pending ? 'Linking...' : 'Link Account'}
        </button>
      </div>
    </form>
  )
}
