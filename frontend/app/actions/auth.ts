'use server'

import { z } from 'zod'
import { redirect } from 'next/navigation'
import { createSession, deleteSession } from '@/app/lib/session'
import { ActionState } from '@/app/lib/definitions'

const API_URL = process.env.API_URL || 'http://localhost:3000'

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
})

const signupSchema = z.object({
  password: z.string().min(8, 'Password must be at least 8 characters'),
  invite_token: z.string().min(1, 'Invitation token is required'),
})

const forgotPasswordSchema = z.object({
  email: z.string().email('Invalid email address'),
})

const resetPasswordSchema = z.object({
  password: z.string().min(8, 'Password must be at least 8 characters'),
  token: z.string().min(1, 'Reset token is required'),
})

export async function login(
  prevState: ActionState | undefined,
  formData: FormData
): Promise<ActionState> {
  const validatedFields = loginSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  })

  if (!validatedFields.success) {
    return { errors: validatedFields.error.flatten().fieldErrors }
  }

  const { email, password } = validatedFields.data

  const response = await fetch(`${API_URL}/api/v1/session`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  })

  if (!response.ok) {
    return { errors: { general: ['Invalid email or password'] } }
  }

  const { token, user } = await response.json()
  await createSession(token, user.id)

  redirect('/')
}

export async function signup(
  prevState: ActionState | undefined,
  formData: FormData
): Promise<ActionState> {
  const validatedFields = signupSchema.safeParse({
    password: formData.get('password'),
    invite_token: formData.get('invite_token'),
  })

  if (!validatedFields.success) {
    return { errors: validatedFields.error.flatten().fieldErrors }
  }

  const { password, invite_token } = validatedFields.data

  const response = await fetch(`${API_URL}/api/v1/users`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password, invite_token }),
  })

  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    return { errors: { general: [error.error || 'Invalid or expired invitation'] } }
  }

  const { token, user } = await response.json()
  await createSession(token, user.id)

  redirect('/')
}

export async function logout(): Promise<void> {
  await deleteSession()
  redirect('/login')
}

export async function forgotPassword(
  prevState: ActionState | undefined,
  formData: FormData
): Promise<ActionState> {
  const validatedFields = forgotPasswordSchema.safeParse({
    email: formData.get('email'),
  })

  if (!validatedFields.success) {
    return { errors: validatedFields.error.flatten().fieldErrors }
  }

  const { email } = validatedFields.data

  await fetch(`${API_URL}/api/v1/password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email }),
  })

  // Always show success (don't reveal if email exists)
  return { success: true }
}

export async function resetPassword(
  prevState: ActionState | undefined,
  formData: FormData
): Promise<ActionState> {
  const validatedFields = resetPasswordSchema.safeParse({
    password: formData.get('password'),
    token: formData.get('token'),
  })

  if (!validatedFields.success) {
    return { errors: validatedFields.error.flatten().fieldErrors }
  }

  const { password, token } = validatedFields.data

  const response = await fetch(`${API_URL}/api/v1/password`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password, token }),
  })

  if (!response.ok) {
    return { errors: { general: ['Invalid or expired reset link'] } }
  }

  return { success: true }
}

export async function verifyInvitation(token: string): Promise<{ email?: string; error?: string }> {
  const response = await fetch(`${API_URL}/api/v1/invitations/verify?token=${token}`)

  if (!response.ok) {
    return { error: 'Invalid or expired invitation' }
  }

  const data = await response.json()
  return { email: data.email }
}
