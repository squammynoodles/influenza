import { cookies } from 'next/headers'
import type { Influencer, YoutubeChannel, TwitterAccount } from './definitions'

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

// Influencer API functions
export async function getInfluencers(token: string): Promise<Influencer[]> {
  const res = await fetch(`${API_URL}/api/v1/influencers`, {
    headers: { Authorization: `Bearer ${token}` },
    cache: 'no-store',
  })
  if (!res.ok) throw new Error('Failed to fetch influencers')
  return res.json()
}

export async function getInfluencer(token: string, id: number): Promise<Influencer> {
  const res = await fetch(`${API_URL}/api/v1/influencers/${id}`, {
    headers: { Authorization: `Bearer ${token}` },
    cache: 'no-store',
  })
  if (!res.ok) throw new Error('Failed to fetch influencer')
  return res.json()
}

export async function createInfluencer(
  token: string,
  data: { name: string; avatar_url?: string; bio?: string }
): Promise<Influencer> {
  const res = await fetch(`${API_URL}/api/v1/influencers`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ influencer: data }),
  })
  if (!res.ok) {
    const error = await res.json()
    throw new Error(error.errors?.join(', ') || 'Failed to create influencer')
  }
  return res.json()
}

export async function updateInfluencer(
  token: string,
  id: number,
  data: { name?: string; avatar_url?: string; bio?: string }
): Promise<Influencer> {
  const res = await fetch(`${API_URL}/api/v1/influencers/${id}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ influencer: data }),
  })
  if (!res.ok) {
    const error = await res.json()
    throw new Error(error.errors?.join(', ') || 'Failed to update influencer')
  }
  return res.json()
}

export async function deleteInfluencer(token: string, id: number): Promise<void> {
  const res = await fetch(`${API_URL}/api/v1/influencers/${id}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${token}` },
  })
  if (!res.ok) throw new Error('Failed to delete influencer')
}

// YouTube Channel API functions
export async function linkYoutubeChannel(
  token: string,
  influencerId: number,
  data: { channel_id: string }
): Promise<YoutubeChannel> {
  const res = await fetch(`${API_URL}/api/v1/influencers/${influencerId}/youtube_channels`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ youtube_channel: data }),
  })
  if (!res.ok) {
    const error = await res.json()
    throw new Error(error.errors?.join(', ') || 'Failed to link YouTube channel')
  }
  return res.json()
}

export async function unlinkYoutubeChannel(
  token: string,
  influencerId: number,
  channelId: number
): Promise<void> {
  const res = await fetch(
    `${API_URL}/api/v1/influencers/${influencerId}/youtube_channels/${channelId}`,
    {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
    }
  )
  if (!res.ok) throw new Error('Failed to unlink YouTube channel')
}

// Twitter Account API functions
export async function linkTwitterAccount(
  token: string,
  influencerId: number,
  data: { username: string }
): Promise<TwitterAccount> {
  const res = await fetch(`${API_URL}/api/v1/influencers/${influencerId}/twitter_accounts`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ twitter_account: data }),
  })
  if (!res.ok) {
    const error = await res.json()
    throw new Error(error.errors?.join(', ') || 'Failed to link Twitter account')
  }
  return res.json()
}

export async function unlinkTwitterAccount(
  token: string,
  influencerId: number,
  accountId: number
): Promise<void> {
  const res = await fetch(
    `${API_URL}/api/v1/influencers/${influencerId}/twitter_accounts/${accountId}`,
    {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
    }
  )
  if (!res.ok) throw new Error('Failed to unlink Twitter account')
}

// Content API functions
export interface ContentFilters {
  type?: 'youtube_video' | 'tweet'
  page?: number
  per_page?: number
}

export async function getInfluencerContents(
  token: string,
  influencerId: number,
  filters: ContentFilters = {}
): Promise<import('./definitions').PaginatedContents> {
  const params = new URLSearchParams()
  if (filters.type) params.set('type', filters.type)
  if (filters.page) params.set('page', filters.page.toString())
  if (filters.per_page) params.set('per_page', filters.per_page.toString())

  const queryString = params.toString()
  const url = `${API_URL}/api/v1/influencers/${influencerId}/contents${queryString ? `?${queryString}` : ''}`

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
    cache: 'no-store',
  })

  if (!res.ok) throw new Error('Failed to fetch contents')
  return res.json()
}

// Content URL helpers
export function getYoutubeThumbnail(videoId: string): string {
  return `https://img.youtube.com/vi/${videoId}/mqdefault.jpg`
}

export function getYoutubeUrl(videoId: string): string {
  return `https://www.youtube.com/watch?v=${videoId}`
}

export function getTweetUrl(username: string, tweetId: string): string {
  return `https://twitter.com/${username}/status/${tweetId}`
}
