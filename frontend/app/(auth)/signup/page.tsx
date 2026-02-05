'use client'

import { useActionState, useEffect, useState } from 'react'
import { useSearchParams } from 'next/navigation'
import { signup, verifyInvitation } from '@/app/actions/auth'
import { Suspense } from 'react'

function SignupForm() {
  const searchParams = useSearchParams()
  const token = searchParams.get('token')

  const [state, action, pending] = useActionState(signup, undefined)
  const [invitation, setInvitation] = useState<{ email?: string; error?: string } | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (token) {
      verifyInvitation(token).then((result) => {
        setInvitation(result)
        setLoading(false)
      })
    } else {
      setInvitation({ error: 'No invitation token provided' })
      setLoading(false)
    }
  }, [token])

  if (loading) {
    return <div className="text-center py-8">Verifying invitation...</div>
  }

  if (invitation?.error) {
    return (
      <div className="text-center py-8">
        <div className="bg-red-50 text-red-600 p-4 rounded-md">
          {invitation.error}
        </div>
        <p className="mt-4 text-sm text-gray-600">
          Please contact an administrator for a new invitation.
        </p>
      </div>
    )
  }

  return (
    <form action={action} className="mt-8 space-y-6">
      <input type="hidden" name="invite_token" value={token || ''} />

      {state?.errors?.general && (
        <div className="bg-red-50 text-red-600 p-3 rounded-md text-sm">
          {state.errors.general.join(', ')}
        </div>
      )}

      <div className="bg-gray-50 p-4 rounded-md">
        <p className="text-sm text-gray-600">Creating account for:</p>
        <p className="font-medium text-gray-900">{invitation?.email}</p>
      </div>

      <div>
        <label htmlFor="password" className="block text-sm font-medium text-gray-700">
          Choose a password
        </label>
        <input
          id="password"
          name="password"
          type="password"
          autoComplete="new-password"
          required
          minLength={8}
          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
        />
        {state?.errors?.password && (
          <p className="mt-1 text-sm text-red-600">{state.errors.password.join(', ')}</p>
        )}
        <p className="mt-1 text-xs text-gray-500">Must be at least 8 characters</p>
      </div>

      <button
        type="submit"
        disabled={pending}
        className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {pending ? 'Creating account...' : 'Create account'}
      </button>
    </form>
  )
}

export default function SignupPage() {
  return (
    <Suspense fallback={<div className="text-center py-8">Loading...</div>}>
      <SignupForm />
    </Suspense>
  )
}
