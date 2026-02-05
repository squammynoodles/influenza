---
phase: 01-foundation-authentication
plan: 03
subsystem: deployment
tags: [railway, docker, postgresql, production]

# Dependency graph
requires:
  - phase: 01-01
    provides: Rails API with authentication
  - phase: 01-02
    provides: Next.js frontend with auth pages
provides:
  - Production deployment on Railway
  - PostgreSQL database provisioned
  - Public URLs for API and frontend
  - CORS configured for cross-origin requests
affects: [02-influencer-management, all-future-phases]

# Tech tracking
tech-stack:
  added: [railway, docker-multi-stage]
  patterns: [standalone-nextjs, railpack-auto-detect]

key-files:
  created:
    - api/.dockerignore
    - frontend/.env.example
  modified:
    - api/config/environments/production.rb
    - api/config/initializers/cors.rb
    - frontend/next.config.ts
    - frontend/package.json

key-decisions:
  - "Use Railway CLI for deployment automation"
  - "Public DATABASE_URL instead of internal (networking issue workaround)"
  - "HOSTNAME=0.0.0.0 for Next.js standalone binding"
  - "No Redis needed - Rails 8 Solid Queue uses PostgreSQL"

# Metrics
duration: 45min
completed: 2026-02-05
---

# Phase 1 Plan 3: Railway Deployment Summary

**Rails API and Next.js frontend deployed to Railway with PostgreSQL**

## Performance

- **Duration:** ~45 min (including troubleshooting)
- **Completed:** 2026-02-05
- **Tasks:** 4 (2 auto, 2 checkpoint)

## Production URLs

| Service | URL |
|---------|-----|
| API | https://api-production-b1ab.up.railway.app |
| Frontend | https://frontend-production-9ba4.up.railway.app |
| Health Check | https://api-production-b1ab.up.railway.app/health |

## Accomplishments

- Rails API deployed with Dockerfile auto-detection
- Next.js frontend deployed with standalone output
- PostgreSQL database provisioned and connected
- Admin user seeded (admin@influenza.local)
- CORS configured for frontend-to-API communication
- All auth flows verified working in production

## Task Commits

1. **Task 1: Prepare Rails API for production** - `708ff7d` (feat)
2. **Task 2: Prepare Next.js for production** - `312aaf2` (feat)
3. **Task 3: Deploy to Railway** - Manual (checkpoint)
4. **Task 4: Verify production** - Manual (checkpoint)

## Environment Variables

**API Service:**
- `RAILS_MASTER_KEY` - Rails credentials decryption
- `DATABASE_URL` - PostgreSQL connection (public URL)
- `FRONTEND_URL` - CORS origin allowlist
- `ADMIN_EMAIL` / `ADMIN_PASSWORD` - Initial admin user
- `PORT=3000` - Rails server port

**Frontend Service:**
- `API_URL` - Backend API endpoint
- `SESSION_SECRET` - JWT encryption key
- `PORT=8080` - Next.js server port
- `HOSTNAME=0.0.0.0` - Bind to all interfaces

## Issues Encountered

1. **Internal hostname not resolving** - Railway's internal DNS (postgres.railway.internal) failed; switched to public DATABASE_URL
2. **Next.js standalone 502** - Required HOSTNAME=0.0.0.0 for proper binding
3. **Monorepo root detection** - Used `--path-as-root` flag for correct directory upload

## Verification Results

| Check | Status |
|-------|--------|
| API /health | ✓ OK |
| Frontend /login | ✓ 200 |
| Admin login | ✓ Token returned |
| Session persistence | ✓ Works across refresh |
| Route protection | ✓ Redirects to /login |

## User Setup Completed

- Railway project created: "influenza"
- PostgreSQL database provisioned
- GitHub repo linked for auto-deploy
- Watch paths recommended for monorepo optimization

---
*Phase: 01-foundation-authentication*
*Completed: 2026-02-05*
