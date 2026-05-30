# EdTech

Node.js + Express + PostgreSQL + Prisma starter.

## Structure

```
src/
  app.js
  server.js
  config/
    env.js
  controllers/
    health.controller.js
    users.controller.js
  db/
    prisma.js
  middlewares/
    error-handler.js
  routes/
    health.routes.js
    index.js
    users.routes.js
  services/
    users.service.js
```

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```
2. Create `.env` from the example and update the database URL:
   ```bash
   copy .env.example .env
   ```
3. Create the database schema:
   ```bash
   npx prisma migrate dev --name init
   ```
4. Start the server:
   ```bash
   npm run dev
   ```

## Endpoints

- `GET /health` — health check
- `GET /users` — list users
- `POST /users` — create user (`{ "name": "...", "email": "..." }`)
