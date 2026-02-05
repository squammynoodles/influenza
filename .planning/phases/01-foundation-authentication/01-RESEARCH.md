# Phase 1: Foundation & Authentication - Research

**Researched:** 2026-02-05
**Domain:** Rails 8 API + Next.js 16 authentication with deployment
**Confidence:** HIGH

## Summary

Phase 1 requires building a Rails 8 API backend with Next.js 16 frontend, implementing authentication for an invite-only platform, and deploying both to production. Research reveals Rails 8 includes a built-in authentication generator that must be adapted for API mode with token-based auth instead of cookies. Next.js 16 uses the App Router with Server Components and Server Actions for authentication flows. Railway supports both Rails and Next.js with zero-config PostgreSQL and Redis provisioning.

The standard approach for separated frontend/backend authentication in 2026 is **token-based authentication** (rather than cross-origin cookies) due to reduced complexity around CORS, SameSite cookie restrictions, and domain configuration. Rails 8's auth generator provides the foundation but requires modifications for API mode. Next.js Server Components + Server Actions + Data Access Layer pattern provides secure, type-safe authentication.

**Primary recommendation:** Use Rails 8 authentication generator adapted for API mode with token-based auth, Next.js 16 Server Actions for auth flows with DAL pattern, and Railway's template deployment for both services with PostgreSQL.

## Standard Stack

### Core - Backend (Rails API)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Ruby on Rails | 8.1.2+ | API backend framework | Built-in auth generator, mature ecosystem, convention over configuration |
| bcrypt | ~> 3.1.7 | Password hashing | Secure password storage, used by has_secure_password |
| rack-cors | latest | Cross-origin requests | Enables Next.js frontend to communicate with Rails API |

**Note:** Rails 8's authentication is built-in, no Devise or other gem needed.

### Core - Frontend (Next.js)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Next.js | 16+ | React framework | App Router with Server Components, production-ready SSR |
| React | 19+ | UI library | Required by Next.js 16 |
| TypeScript | 5.1.0+ | Type safety | Default in Next.js 16, catches auth errors at compile time |
| jose | latest | JWT handling | Lightweight, standards-compliant JWT library for Node.js |
| zod | latest | Schema validation | Runtime validation for auth forms, type-safe error messages |

### Supporting - Backend
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| PostgreSQL | 15+ | Primary database | User accounts, sessions, invitations |
| Redis | 7+ | (Future) Background jobs | When adding email sending via Sidekiq/SolidQueue |

### Supporting - Frontend
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Tailwind CSS | latest | Styling | Default in Next.js 16 setup, rapid UI development |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Token-based auth | Cookie-based with CORS | Cookies require complex CORS + SameSite configuration, domain alignment |
| Rails 8 built-in auth | Devise | Devise adds unnecessary complexity for simple use case, Rails 8 auth is sufficient |
| jose (JWT) | jsonwebtoken | jose is more modern, better maintained, supports latest standards |
| Next.js Server Actions | Client-side auth (React hooks) | Server Actions are more secure, no token exposure to browser |

**Installation:**
```bash
# Backend
rails new api --api --database=postgresql
cd api
bundle add rack-cors

# Frontend (separate directory)
npx create-next-app@latest frontend --typescript --tailwind --app --no-src-dir
cd frontend
npm install jose zod
```

## Architecture Patterns

### Recommended Project Structure
```
/
├── api/                     # Rails API backend
│   ├── app/
│   │   ├── controllers/
│   │   │   ├── concerns/
│   │   │   │   └── authentication.rb    # Token-based auth logic
│   │   │   ├── api/                      # API namespace
│   │   │   │   └── v1/                   # Versioned API
│   │   │   │       ├── sessions_controller.rb
│   │   │   │       ├── passwords_controller.rb
│   │   │   │       └── invitations_controller.rb
│   │   │   └── application_controller.rb
│   │   ├── models/
│   │   │   ├── user.rb
│   │   │   ├── session.rb
│   │   │   ├── current.rb
│   │   │   └── invitation.rb
│   │   └── mailers/
│   │       └── passwords_mailer.rb
│   └── config/
│       └── initializers/
│           └── cors.rb                   # CORS configuration
├── frontend/                # Next.js frontend
│   ├── app/
│   │   ├── (auth)/                       # Auth routes group
│   │   │   ├── login/
│   │   │   ├── signup/
│   │   │   └── reset-password/
│   │   ├── lib/
│   │   │   ├── dal.ts                    # Data Access Layer
│   │   │   ├── session.ts                # Session management
│   │   │   └── api.ts                    # API client
│   │   └── actions/
│   │       └── auth.ts                   # Server Actions
│   └── middleware.ts                     # Route protection
```

### Pattern 1: Token-Based API Authentication
**What:** Rails API returns JWT tokens on login, Next.js stores in httpOnly cookies, sends in Authorization header for API requests.
**When to use:** Separated frontend/backend architecture (our case).
**Example:**
```typescript
// Source: https://nextjs.org/docs/app/guides/authentication + Rails API adaptation
// Next.js Server Action (app/actions/auth.ts)
'use server'
import { SignJWT } from 'jose'
import { cookies } from 'next/headers'

export async function login(formData: FormData) {
  // Call Rails API
  const response = await fetch(`${process.env.API_URL}/api/v1/sessions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: formData.get('email'),
      password: formData.get('password')
    })
  })

  if (!response.ok) {
    return { error: 'Invalid credentials' }
  }

  const { token } = await response.json()

  // Store token in httpOnly cookie
  const cookieStore = await cookies()
  cookieStore.set('session', token, {
    httpOnly: true,
    secure: true,
    sameSite: 'lax',
    maxAge: 60 * 60 * 24 * 7 // 7 days
  })

  return { success: true }
}
```

```ruby
# Source: https://avohq.io/blog/rails-api-authentication-with-the-auth-generator
# Rails API Controller (app/controllers/api/v1/sessions_controller.rb)
class Api::V1::SessionsController < ApplicationController
  skip_before_action :require_authentication

  def create
    user = User.find_by(email_address: params[:email])

    if user&.authenticate(params[:password])
      session = user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      )

      render json: { token: session.token, user: user.as_json(only: [:id, :email_address]) }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
```

### Pattern 2: Data Access Layer (DAL) for Session Verification
**What:** Centralize session verification and user fetching in a single place, use React's cache() to prevent duplicate queries.
**When to use:** All Server Components and Server Actions that need current user.
**Example:**
```typescript
// Source: https://nextjs.org/docs/app/guides/authentication
// app/lib/dal.ts
import 'server-only'
import { cache } from 'react'
import { cookies } from 'next/headers'
import { jwtVerify } from 'jose'

export const verifySession = cache(async () => {
  const cookieStore = await cookies()
  const token = cookieStore.get('session')?.value

  if (!token) {
    return { isAuth: false }
  }

  try {
    const secret = new TextEncoder().encode(process.env.SESSION_SECRET)
    const { payload } = await jwtVerify(token, secret)

    return {
      isAuth: true,
      userId: payload.userId as string
    }
  } catch (error) {
    return { isAuth: false }
  }
})

export const getUser = cache(async () => {
  const session = await verifySession()

  if (!session.isAuth) {
    return null
  }

  // Fetch user from Rails API
  const response = await fetch(`${process.env.API_URL}/api/v1/users/${session.userId}`, {
    headers: {
      'Authorization': `Bearer ${session.userId}`
    }
  })

  if (!response.ok) {
    return null
  }

  return response.json()
})
```

### Pattern 3: Invite-Only Registration with generates_token_for
**What:** Admin creates invitation records with time-limited tokens, users register via emailed link.
**When to use:** Invite-only platforms (our requirement AUTH-02).
**Example:**
```ruby
# Source: https://railsdesigner.com/saas/invite-to-rails-8-authentication/
# app/models/invitation.rb
class Invitation < ApplicationRecord
  belongs_to :invited_by, class_name: "User"

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # Token expires in 7 days, becomes invalid once accepted_at is set
  generates_token_for :invitation, expires_in: 7.days do
    accepted_at
  end

  def accepted?
    accepted_at.present?
  end
end

# app/controllers/api/v1/invitations_controller.rb
class Api::V1::InvitationsController < ApplicationController
  # Admin creates invitation
  def create
    invitation = Invitation.new(
      email: params[:email],
      invited_by: Current.user
    )

    if invitation.save
      token = invitation.generate_token_for(:invitation)
      # Send email with signup link containing token
      InvitationsMailer.invite(invitation, token).deliver_later
      render json: { invitation: invitation }, status: :created
    else
      render json: { errors: invitation.errors }, status: :unprocessable_entity
    end
  end

  # Verify invitation token (called by signup form)
  def verify
    invitation = Invitation.find_by_token_for(:invitation, params[:token])

    if invitation
      render json: { email: invitation.email }
    else
      render json: { error: "Invalid or expired invitation" }, status: :unprocessable_entity
    end
  end
end
```

### Pattern 4: Railway Deployment Configuration
**What:** Use environment variables for configuration, Dockerfile for Rails, automatic detection for Next.js.
**When to use:** Production deployment to Railway.
**Example:**
```yaml
# Source: https://docs.railway.com/guides/rails
# Railway service configuration (inferred from docs)
# Rails API Service
services:
  api:
    build:
      dockerfile: Dockerfile
    env:
      RAILS_ENV: production
      RAILS_MASTER_KEY: ${{secrets.RAILS_MASTER_KEY}}
      DATABASE_URL: ${{Postgres.DATABASE_URL}}
      REDIS_URL: ${{Redis.REDIS_URL}}
    start_command: bin/rails server -b ::
    healthcheck: /health

# Next.js Frontend Service
  frontend:
    build_command: npm run build
    start_command: npm start
    env:
      API_URL: ${{api.RAILWAY_PRIVATE_DOMAIN}}
      SESSION_SECRET: ${{secrets.SESSION_SECRET}}
```

### Anti-Patterns to Avoid
- **Cookie-based cross-origin auth:** Requires complex CORS configuration, SameSite=None, domain alignment issues
- **Tokens in localStorage:** Vulnerable to XSS attacks, use httpOnly cookies instead
- **Skipping CORS configuration:** Next.js frontend will fail to call Rails API
- **Using Context Providers for auth in Server Components:** Context doesn't work reliably, use DAL pattern
- **Exposing RAILS_MASTER_KEY in version control:** Use environment variables, never commit secrets
- **Not using API versioning (e.g., /api/v1/):** Makes breaking changes difficult later

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Password hashing | Custom hash function | bcrypt via has_secure_password | Industry-standard, timing-attack resistant, proper salt handling |
| JWT generation/verification | Custom JWT implementation | jose library | Handles edge cases (expiry, algorithm mismatches, signature verification) |
| Form validation | Manual param checking | Zod schemas | Type-safe, reusable, automatic error messages |
| Session token generation | SecureRandom.hex | generates_token_for | Built-in expiry, single-use tokens, database-backed |
| Password reset flow | Custom token table | generates_token_for :password_reset | Rails 8 built-in, signed tokens, automatic expiry (15 min) |
| CORS configuration | Manual headers | rack-cors gem | Handles preflight requests, credential support, origin wildcarding |
| Email delivery | Direct SMTP | ActionMailer with deliver_later | Background processing, retry logic, production email services |

**Key insight:** Authentication has critical security implications. Edge cases (timing attacks, token replay, session fixation) are subtle and well-handled by established libraries. Custom implementations miss these protections.

## Common Pitfalls

### Pitfall 1: Cross-Origin Session Cookies Don't Work
**What goes wrong:** Attempting to use Rails session cookies with Next.js frontend results in cookies not being stored by browser.
**Why it happens:** Browsers block third-party cookies by default. SameSite=None requires Secure flag (HTTPS) and domain configuration is complex.
**How to avoid:** Use token-based authentication. Rails returns token in JSON, Next.js stores in httpOnly cookie on same domain, sends token to Rails in Authorization header.
**Warning signs:** "Set-Cookie header present but cookie not stored in browser DevTools"

### Pitfall 2: CORS Configured After ActionDispatch Middleware
**What goes wrong:** CORS headers not applied, preflight requests fail with 404 or 403.
**Why it happens:** rack-cors must be positioned above other middleware in stack. If authentication middleware runs first, it blocks preflight OPTIONS requests.
**How to avoid:** In config/application.rb, configure rack-cors with `config.middleware.insert_before 0, Rack::Cors`. Enable credentials: true and include allowed headers.
**Warning signs:** Browser console shows "CORS policy blocked", OPTIONS requests return 404

### Pitfall 3: Rails API Mode Missing Cookie/Session Middleware
**What goes wrong:** If using cookie-based sessions, they don't persist because ActionDispatch::Cookies not included.
**Why it happens:** Rails API mode strips non-API middleware by default.
**How to avoid:** For token-based auth (recommended), this is not needed. If using cookies, add to config/application.rb: `config.middleware.use ActionDispatch::Cookies` and `config.middleware.use ActionDispatch::Session::CookieStore`.
**Warning signs:** Sessions work in development but not when deployed, cookies not set

### Pitfall 4: Environment Variables Not Loaded at Build Time (Next.js)
**What goes wrong:** NEXT_PUBLIC_ prefixed variables work, but non-public variables are undefined in Server Components.
**Why it happens:** Public variables are inlined at build time. Non-public variables must be available at runtime.
**How to avoid:** Use NEXT_PUBLIC_ prefix only for values safe to expose to browser. For API_URL accessed in Server Actions, ensure environment variable set at runtime (Railway handles this automatically).
**Warning signs:** API_URL is undefined in production but works locally

### Pitfall 5: Invitation Tokens Not Expiring or Single-Use
**What goes wrong:** Users can reuse invitation link multiple times, or tokens never expire.
**Why it happens:** Custom token implementations often miss expiry logic or single-use validation.
**How to avoid:** Use generates_token_for with expires_in and block parameter that changes when invitation accepted (e.g., `do accepted_at end`). Token becomes invalid once accepted_at is set.
**Warning signs:** Multiple users register with same invitation link, old invitations still work after weeks

### Pitfall 6: Password Reset Tokens Stored in Database
**What goes wrong:** Token leak via database breach allows account takeover.
**Why it happens:** Old patterns stored reset_token column in users table.
**How to avoid:** Rails 8 generates_token_for :password_reset creates signed, time-limited tokens (15 min default) that are NOT stored in database. Token is verified via signature, not lookup.
**Warning signs:** Migration includes add_column :users, :reset_token

### Pitfall 7: Not Using ActionMailer deliver_later in Production
**What goes wrong:** HTTP requests timeout waiting for email sending, poor user experience.
**Why it happens:** deliver_now is synchronous, blocks request until SMTP completes.
**How to avoid:** Use deliver_later for all production emails. Requires background job processor (Sidekiq with Redis, or SolidQueue). Railway templates include Redis by default.
**Warning signs:** Slow password reset/invitation requests (2-5 seconds), timeouts

## Code Examples

Verified patterns from official sources:

### Example 1: Rails API Authentication Concern
```ruby
# Source: https://avohq.io/blog/rails-api-authentication-with-the-auth-generator
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  private

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    if session = find_session_by_token
      Current.session = session
      Current.user = session.user
    end
  end

  def find_session_by_token
    authenticate_with_http_token do |token, options|
      Session.find_by(token: token)
    end
  end

  def request_authentication
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def authenticated?
    Current.user.present?
  end
end
```

### Example 2: Next.js Login Form with Server Action
```tsx
// Source: https://nextjs.org/docs/app/guides/authentication
// app/(auth)/login/page.tsx
'use client'
import { login } from '@/app/actions/auth'
import { useActionState } from 'react'

export default function LoginPage() {
  const [state, action, pending] = useActionState(login, undefined)

  return (
    <form action={action}>
      <div>
        <label htmlFor="email">Email</label>
        <input id="email" name="email" type="email" required />
        {state?.errors?.email && <p>{state.errors.email}</p>}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input id="password" name="password" type="password" required />
        {state?.errors?.password && <p>{state.errors.password}</p>}
      </div>

      {state?.error && <p className="error">{state.error}</p>}

      <button disabled={pending} type="submit">
        {pending ? 'Logging in...' : 'Log In'}
      </button>
    </form>
  )
}
```

### Example 3: Protected Route with Middleware
```typescript
// Source: https://nextjs.org/docs/app/guides/authentication
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const sessionCookie = request.cookies.get('session')

  // If no session and trying to access protected route
  if (!sessionCookie && !request.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // If has session and trying to access auth pages
  if (sessionCookie && request.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)']
}
```

### Example 4: CORS Configuration for Rails API
```ruby
# Source: https://www.stackhawk.com/blog/rails-cors-guide/
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['FRONTEND_URL'] || 'http://localhost:3001'

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization']
  end
end
```

### Example 5: Session Model with Token
```ruby
# Source: https://avohq.io/blog/rails-api-authentication-with-the-auth-generator
# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :user

  has_secure_token :token

  before_create do
    self.user_agent = user_agent
    self.ip_address = ip_address
  end

  def self.cleanup_expired
    where("created_at < ?", 7.days.ago).destroy_all
  end
end

# Migration
class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.string :user_agent
      t.string :ip_address
      t.timestamps
    end

    add_index :sessions, :token, unique: true
  end
end
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Devise gem | Rails 8 built-in auth | Rails 8.0 (Oct 2024) | Simpler setup, less code, easier to customize |
| JWT in localStorage | JWT in httpOnly cookies | ~2020-2021 | XSS protection, more secure token storage |
| NextAuth.js v4 | Auth.js v5 | 2025 | Better App Router support, Server Components integration |
| Pages Router | App Router | Next.js 13+ (2023) | Server Components, colocation, Server Actions |
| next build | next build with Turbopack | Next.js 16 (2025) | Faster builds (10x claimed), stable in production |
| Node.js 18 | Node.js 20.9+ | Next.js 16 requirement | Modern APIs, performance improvements |

**Deprecated/outdated:**
- Devise for simple auth: Rails 8 built-in is now sufficient for basic use cases
- jsonwebtoken npm package: jose is more modern and standards-compliant
- Context Providers for auth in App Router: DAL pattern with cache() is correct approach
- Storing reset tokens in database: generates_token_for creates signed tokens, no storage needed
- SameSite=None cookie auth for SPAs: Token-based is simpler and more reliable

## Open Questions

Things that couldn't be fully resolved:

1. **Email Service for Production**
   - What we know: ActionMailer needs 3rd party service (Mailgun, SendGrid, Postmark) for production email delivery
   - What's unclear: Railway doesn't provide built-in email service, requires external account
   - Recommendation: Defer email configuration to execution phase. Password reset and invitations can be tested locally with letter_opener gem. Choose email service during implementation based on pricing (all have free tiers).

2. **Next.js Hosting Choice (Railway vs Vercel)**
   - What we know: Railway supports Next.js with auto-detection, Vercel is Next.js creators
   - What's unclear: Railway pricing for Next.js at scale vs Vercel free tier limits
   - Recommendation: Start with Railway to keep both services in one platform. Migration to Vercel is straightforward if needed (Next.js is portable).

3. **Redis Requirement Timing**
   - What we know: Redis needed for deliver_later background jobs (Sidekiq/SolidQueue)
   - What's unclear: Whether Phase 1 needs Redis immediately or can defer until email configured
   - Recommendation: Add Redis service in Railway from start (free tier available). Will be needed for Phase 2+ anyway (background content ingestion).

4. **API Versioning Strategy**
   - What we know: /api/v1/ namespace is best practice for future breaking changes
   - What's unclear: Whether v1 is overkill for initial private API
   - Recommendation: Use /api/v1/ from start. Minimal overhead (one directory level), prevents future refactoring.

## Sources

### Primary (HIGH confidence)
- [Next.js Official Docs - Authentication](https://nextjs.org/docs/app/guides/authentication) - App Router auth patterns, DAL, Server Actions
- [Next.js Official Docs - Environment Variables](https://nextjs.org/docs/pages/guides/environment-variables) - Build-time vs runtime behavior
- [Rails Official Guides - Getting Started](https://guides.rubyonrails.org/getting_started.html) - Rails 8.1 authentication generator
- [Railway Docs - Deploy Rails](https://docs.railway.com/guides/rails) - Environment variables, deployment steps
- [Railway Docs - PostgreSQL](https://docs.railway.com/guides/postgresql) - Database configuration
- [Railway Docs - Redis](https://docs.railway.com/guides/redis) - Redis setup for background jobs

### Secondary (MEDIUM confidence)
- [Avo Blog - Rails API Authentication with the Auth Generator](https://avohq.io/blog/rails-api-authentication-with-the-auth-generator) - Adapting Rails 8 auth for API mode
- [Saeloun Blog - Rails 8 Adds Built-in Authentication Generator](https://blog.saeloun.com/2025/05/12/rails-8-adds-built-in-authentication-generator/) - Generated files and structure
- [Rails Designer - Add Invite to Rails 8 Authentication](https://railsdesigner.com/saas/invite-to-rails-8-authentication/) - generates_token_for invitation pattern
- [StackHawk - Mastering CORS in Your Rails API](https://www.stackhawk.com/blog/rails-cors-guide/) - CORS configuration patterns
- [Next.js Blog - Next.js 16](https://nextjs.org/blog/next-16) - Turbopack stable, React Compiler support
- [Auth0 Blog - Using Next.js Server Actions to Call External APIs](https://auth0.com/blog/using-nextjs-server-actions-to-call-external-apis/) - Server Actions with external APIs
- [Medium - User Invitations with Rails 8 Authentication](https://medium.com/deemaze-software/user-invitations-with-rails-8-authentication-ba229fab466e) - Invitation implementation details
- [Authgear - Session vs Token Authentication](https://www.authgear.com/post/session-vs-token-authentication) - Token-based auth rationale
- [TheLinuxCode - Next.js Environment Variables (2026)](https://thelinuxcode.com/nextjs-environment-variables-2026-build-time-vs-runtime-security-and-production-patterns/) - Production patterns

### Tertiary (LOW confidence - needs validation during implementation)
- Various Medium articles on Rails 8 + React authentication patterns
- Community discussions on Next.js + Rails integration
- Railway template examples (Rails 8 + Hotwire)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official docs confirm Rails 8 auth, Next.js 16 App Router, Railway support
- Architecture: HIGH - Next.js official docs provide DAL pattern, Rails API adaptation verified in multiple sources
- Pitfalls: MEDIUM - Common issues well-documented but some are experiential (e.g., CORS ordering)
- Email service choice: LOW - Deferred decision, multiple valid options

**Research date:** 2026-02-05
**Valid until:** ~30 days (Rails 8 stable, Next.js 16 stable, patterns mature)

**Key uncertainties for planning:**
- Email service selection (recommend deferring)
- Railway vs Vercel for frontend (recommend starting with Railway)
- Redis immediate need (recommend adding from start, low cost)
