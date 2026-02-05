import 'server-only'
import { cache } from 'react'
import { getSession } from './session'
import { apiRequest } from './api'
import { User } from './definitions'

export const verifySession = cache(async () => {
  const session = await getSession()

  if (!session) {
    return { isAuth: false as const }
  }

  return {
    isAuth: true as const,
    userId: session.userId,
    token: session.token,
  }
})

export const getUser = cache(async (): Promise<User | null> => {
  const session = await verifySession()

  if (!session.isAuth) {
    return null
  }

  const { data, error } = await apiRequest<User>(`/api/v1/users/${session.userId}`)

  if (error || !data) {
    return null
  }

  return data
})
