export interface User {
  id: number
  email_address: string
  admin: boolean
}

export interface SessionPayload {
  token: string
  userId: number
  expiresAt: Date
}

export interface ActionState {
  errors?: {
    email?: string[]
    password?: string[]
    general?: string[]
  }
  success?: boolean
}

// Influencer types
export interface Influencer {
  id: number
  name: string
  avatar_url: string | null
  bio: string | null
  youtube_channels: YoutubeChannel[]
  twitter_accounts: TwitterAccount[]
  created_at: string
  updated_at: string
}

export interface YoutubeChannel {
  id: number
  influencer_id: number
  channel_id: string
  title: string | null
  description: string | null
  thumbnail_url: string | null
  uploads_playlist_id: string | null
  last_synced_at: string | null
}

export interface TwitterAccount {
  id: number
  influencer_id: number
  username: string
  display_name: string | null
  profile_image_url: string | null
  bio: string | null
  last_synced_at: string | null
}

export interface Content {
  id: number
  influencer_id: number
  type: 'YoutubeVideo' | 'Tweet'
  external_id: string
  title: string | null
  body: string | null
  transcript: string | null
  published_at: string
  metadata: Record<string, unknown>
}

export interface PaginatedContents {
  contents: Content[]
  meta: {
    total: number
    page: number
    per_page: number
  }
}

export interface InfluencerActionState {
  error?: string
  success?: boolean
}
