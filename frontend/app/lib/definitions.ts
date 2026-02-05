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
