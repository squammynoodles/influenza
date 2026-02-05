'use client'

import { useActionState } from 'react'
import { forgotPassword } from '@/app/actions/auth'
import Link from 'next/link'

export default function ForgotPasswordPage() {
  const [state, action, pending] = useActionState(forgotPassword, undefined)

  if (state?.success) {
    return (
      <div className="mt-8 space-y-6">
        <div className="bg-green-50 text-green-600 p-4 rounded-md text-center">
          <p className="font-medium">Check your email</p>
          <p className="mt-1 text-sm">
            If an account exists with that email, we&apos;ve sent password reset instructions.
          </p>
        </div>
        <Link
          href="/login"
          className="block text-center text-sm text-indigo-600 hover:text-indigo-500"
        >
          Return to login
        </Link>
      </div>
    )
  }

  return (
    <form action={action} className="mt-8 space-y-6">
      <p className="text-sm text-gray-600">
        Enter your email address and we&apos;ll send you a link to reset your password.
      </p>

      {state?.errors?.general && (
        <div className="bg-red-50 text-red-600 p-3 rounded-md text-sm">
          {state.errors.general.join(', ')}
        </div>
      )}

      <div>
        <label htmlFor="email" className="block text-sm font-medium text-gray-700">
          Email address
        </label>
        <input
          id="email"
          name="email"
          type="email"
          autoComplete="email"
          required
          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
        />
        {state?.errors?.email && (
          <p className="mt-1 text-sm text-red-600">{state.errors.email.join(', ')}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={pending}
        className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {pending ? 'Sending...' : 'Send reset link'}
      </button>

      <Link
        href="/login"
        className="block text-center text-sm text-indigo-600 hover:text-indigo-500"
      >
        Back to login
      </Link>
    </form>
  )
}
