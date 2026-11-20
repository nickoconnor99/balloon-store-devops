# Stage 1: Install dependencies
FROM node:20-alpine AS deps

RUN apk add --no-cache openssl

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

# Stage 2: Build the Next.js application
FROM node:20-alpine AS builder

RUN apk add --no-cache openssl

WORKDIR /app

# Public Supabase configuration required during Next.js build
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_KEY

ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
ENV NEXT_PUBLIC_SUPABASE_KEY=$NEXT_PUBLIC_SUPABASE_KEY

COPY --from=deps /app/node_modules ./node_modules

COPY . .

RUN npm run build

# Stage 3: Production runner
FROM node:20-alpine AS runner

RUN apk add --no-cache openssl

WORKDIR /app

# Public Supabase configuration required during Next.js build

ENV NODE_ENV=production

# Create a non-root user
RUN addgroup -S -g 1001 nodejs && adduser -S -u 1001 nextjs

# Copy public assets
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Copy standalone application
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./

# Copy static assets
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Run as non-root user
USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]