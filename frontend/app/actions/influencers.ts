'use server'

import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'
import { verifySession, getUser } from '@/app/lib/dal'
import * as api from '@/app/lib/api'
import { z } from 'zod'
import type { InfluencerActionState } from '@/app/lib/definitions'

const InfluencerSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100, 'Name must be 100 characters or less'),
  avatar_url: z
    .string()
    .url('Avatar URL must be a valid URL')
    .optional()
    .or(z.literal('')),
  bio: z.string().max(1000, 'Bio must be 1000 characters or less').optional(),
})

const YoutubeChannelSchema = z.object({
  channel_id: z.string().min(1, 'Channel ID is required'),
  uploads_playlist_id: z.string().optional().or(z.literal('')),
})

const TwitterAccountSchema = z.object({
  username: z.string().min(1, 'Username is required'),
})

async function requireAdmin() {
  const session = await verifySession()
  if (!session.isAuth) {
    return { error: 'Authentication required', token: null, isAdmin: false }
  }

  const user = await getUser()
  if (!user?.admin) {
    return { error: 'Admin access required', token: null, isAdmin: false }
  }

  return { error: null, token: session.token, isAdmin: true }
}

export async function createInfluencer(
  prevState: InfluencerActionState | null,
  formData: FormData
): Promise<InfluencerActionState> {
  const auth = await requireAdmin()
  if (auth.error) {
    return { error: auth.error }
  }

  const parsed = InfluencerSchema.safeParse({
    name: formData.get('name'),
    avatar_url: formData.get('avatar_url') || undefined,
    bio: formData.get('bio') || undefined,
  })

  if (!parsed.success) {
    return { error: parsed.error.issues[0].message }
  }

  try {
    const data = {
      name: parsed.data.name,
      avatar_url: parsed.data.avatar_url || undefined,
      bio: parsed.data.bio || undefined,
    }
    await api.createInfluencer(auth.token!, data)
    revalidatePath('/influencers')
  } catch (e) {
    return { error: e instanceof Error ? e.message : 'Failed to create influencer' }
  }

  redirect('/influencers')
}

export async function updateInfluencer(
  id: number,
  prevState: InfluencerActionState | null,
  formData: FormData
): Promise<InfluencerActionState> {
  const auth = await requireAdmin()
  if (auth.error) {
    return { error: auth.error }
  }

  const parsed = InfluencerSchema.safeParse({
    name: formData.get('name'),
    avatar_url: formData.get('avatar_url') || undefined,
    bio: formData.get('bio') || undefined,
  })

  if (!parsed.success) {
    return { error: parsed.error.issues[0].message }
  }

  try {
    const data = {
      name: parsed.data.name,
      avatar_url: parsed.data.avatar_url || undefined,
      bio: parsed.data.bio || undefined,
    }
    await api.updateInfluencer(auth.token!, id, data)
    revalidatePath('/influencers')
    revalidatePath(`/influencers/${id}`)
  } catch (e) {
    return { error: e instanceof Error ? e.message : 'Failed to update influencer' }
  }

  redirect(`/influencers/${id}`)
}

export async function deleteInfluencer(id: number): Promise<void> {
  const auth = await requireAdmin()
  if (auth.error) {
    throw new Error(auth.error)
  }

  await api.deleteInfluencer(auth.token!, id)
  revalidatePath('/influencers')
  redirect('/influencers')
}

export async function linkYoutubeChannel(
  influencerId: number,
  prevState: InfluencerActionState | null,
  formData: FormData
): Promise<InfluencerActionState> {
  const auth = await requireAdmin()
  if (auth.error) {
    return { error: auth.error }
  }

  const parsed = YoutubeChannelSchema.safeParse({
    channel_id: formData.get('channel_id'),
    uploads_playlist_id: formData.get('uploads_playlist_id') || undefined,
  })

  if (!parsed.success) {
    return { error: parsed.error.issues[0].message }
  }

  try {
    const data = {
      channel_id: parsed.data.channel_id,
      uploads_playlist_id: parsed.data.uploads_playlist_id || undefined,
    }
    await api.linkYoutubeChannel(auth.token!, influencerId, data)
    revalidatePath(`/influencers/${influencerId}`)
  } catch (e) {
    return { error: e instanceof Error ? e.message : 'Failed to link YouTube channel' }
  }

  return { success: true }
}

export async function linkTwitterAccount(
  influencerId: number,
  prevState: InfluencerActionState | null,
  formData: FormData
): Promise<InfluencerActionState> {
  const auth = await requireAdmin()
  if (auth.error) {
    return { error: auth.error }
  }

  const parsed = TwitterAccountSchema.safeParse({
    username: formData.get('username'),
  })

  if (!parsed.success) {
    return { error: parsed.error.issues[0].message }
  }

  try {
    await api.linkTwitterAccount(auth.token!, influencerId, { username: parsed.data.username })
    revalidatePath(`/influencers/${influencerId}`)
  } catch (e) {
    return { error: e instanceof Error ? e.message : 'Failed to link Twitter account' }
  }

  return { success: true }
}

export async function unlinkYoutubeChannel(
  influencerId: number,
  channelId: number
): Promise<void> {
  const auth = await requireAdmin()
  if (auth.error) {
    throw new Error(auth.error)
  }

  await api.unlinkYoutubeChannel(auth.token!, influencerId, channelId)
  revalidatePath(`/influencers/${influencerId}`)
}

export async function unlinkTwitterAccount(
  influencerId: number,
  accountId: number
): Promise<void> {
  const auth = await requireAdmin()
  if (auth.error) {
    throw new Error(auth.error)
  }

  await api.unlinkTwitterAccount(auth.token!, influencerId, accountId)
  revalidatePath(`/influencers/${influencerId}`)
}
