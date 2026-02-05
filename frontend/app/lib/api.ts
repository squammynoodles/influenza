import { cookies } from 'next/headers'

const API_URL = process.env.API_URL || 'http://localhost:3000'

export async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<{ data?: T; error?: string; status: number }> {
  const cookieStore = await cookies()
  const token = cookieStore.get('session')?.value

  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(token && { Authorization: `Bearer ${token}` }),
    ...options.headers,
  }

  try {
    const response = await fetch(`${API_URL}${endpoint}`, {
      ...options,
      headers,
    })

    const data = response.ok ? await response.json() : null
    const error = !response.ok
      ? (await response.json().catch(() => ({ error: 'Request failed' }))).error
      : undefined

    return { data, error, status: response.status }
  } catch (error) {
    return { error: 'Network error', status: 0 }
  }
}
