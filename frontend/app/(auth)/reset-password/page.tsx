'use client'

import { useActionState } from 'react'
import { useSearchParams } from 'next/navigation'
import { resetPassword } from '@/app/actions/auth'
import Link from 'next/link'
import { Suspense } from 'react'

function ResetPasswordForm() {
  const searchParams = useSearchParams()
  const token = searchParams.get('token')

  const [state, action, pending] = useActionState(resetPassword, undefined)

  if (!token) {
    return (
      <div className="mt-8 text-center">
        <div className="bg-red-50 text-red-600 p-4 rounded-md">
          Invalid reset link. Please request a new password reset.
        </div>
        <Link
          href="/forgot-password"
          className="mt-4 inline-block text-sm text-indigo-600 hover:text-indigo-500"
        >
          Request new reset link
        </Link>
      </div>
    )
  }

  if (state?.success) {
    return (
      <div className="mt-8 space-y-6">
        <div className="bg-green-50 text-green-600 p-4 rounded-md text-center">
          <p className="font-medium">Password updated!</p>
          <p className="mt-1 text-sm">
            Your password has been reset successfully.
          </p>
        </div>
        <Link
          href="/login"
          className="block text-center w-full py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
        >
          Sign in with new password
        </Link>
      </div>
    )
  }

  return (
    <form action={action} className="mt-8 space-y-6">
      <input type="hidden" name="token" value={token} />

      {state?.errors?.general && (
        <div className="bg-red-50 text-red-600 p-3 rounded-md text-sm">
          {state.errors.general.join(', ')}
        </div>
      )}

      <div>
        <label htmlFor="password" className="block text-sm font-medium text-gray-700">
          New password
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
        {pending ? 'Resetting...' : 'Reset password'}
      </button>
    </form>
  )
}

export default function ResetPasswordPage() {
  return (
    <Suspense fallback={<div className="text-center py-8">Loading...</div>}>
      <ResetPasswordForm />
    </Suspense>
  )
}
