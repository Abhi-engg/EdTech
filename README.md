# EdTech

Node.js + Express + PostgreSQL + Prisma starter.

## Structure

```
src/
  app.js
  server.js
  auth/
    auth.js
  config/
    env.js
  controllers/
    auth.controller.js
    health.controller.js
    users.controller.js
  db/
    prisma.js
  middlewares/
    error-handler.js
  routes/
    auth.routes.js
    health.routes.js
    index.js
    users.routes.js
  services/
    auth.service.js
    users.service.js
  utils/
    email.js
    http.js
```

## Setup

1. Use Node.js 20.19+.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create `.env` from the example and update the database URL:
   ```bash
   copy .env.example .env
   ```
4. Generate a Better Auth secret:
   ```bash
   npx auth@latest secret
   ```
5. Add Better Auth tables to your database by creating a Prisma migration after the schema update:
   ```bash
   npx prisma migrate dev --name add-better-auth
   ```
   If you're starting with an empty database, run your existing app migrations first.
6. Start the server:
   ```bash
   npm run dev
   ```

## Endpoints

- `GET /health` — health check
- `GET /users` — list users
- `POST /users` — create user (`{ "name": "...", "email": "..." }`)
- `POST /auth/sign-in`
- `POST /auth/sign-out`
- `GET /auth/session`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `POST /auth/first-login`
- `POST /auth/admin/invite` (protect this route in production)

## Auth Flow

- Admin uses `/auth/admin/invite` to create a user and trigger a reset link.
- User signs in, then completes `/auth/first-login` to set a new password and clear `firstLogin`.
