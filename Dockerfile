FROM oven/bun:1-alpine AS base

# Install turbo
FROM base AS prune
WORKDIR /app
RUN bun install -g turbo
COPY . .
RUN turbo prune @kejue/docs --docker

FROM base AS builder
WORKDIR /app

# Build arguments for environment variables that need to be available at build time
ARG OPENAI_API_KEY=sk-dsdsa
ARG NEXT_PUBLIC_BASE_URL=https://docs.chorus-ai.co

# Set them as environment variables for the build process
ENV OPENAI_API_KEY=${OPENAI_API_KEY}
ENV NEXT_PUBLIC_BASE_URL=${NEXT_PUBLIC_BASE_URL}

# Copy lockfile and package.json's of isolated subworkspace
COPY --from=prune /app/out/json/ .
COPY --from=prune /app/out/bun.lock ./bun.lock

# Install dependencies, ignoring scripts initially to avoid vite dependency issues
RUN bun install --frozen-lockfile --ignore-scripts

# Patch fumadocs-openapi icons to use lucide-react directly (version incompatibility workaround)
RUN echo "export { Check, Copy, ChevronDown, ChevronUp } from 'lucide-react';" > node_modules/fumadocs-openapi/dist/icons.js

# Build the project
COPY --from=prune /app/out/full/ .

# Now run fumadocs-mdx setup after source files are available
RUN cd apps/docs-new && bun run fumadocs-mdx

# Build with turbo
RUN bun run build --filter=@kejue/docs

FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Set the correct permission for prune .next
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/apps/docs-new/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/apps/docs-new/.next/static ./apps/docs-new/.next/static
COPY --from=builder --chown=nextjs:nodejs /app/apps/docs-new/public ./apps/docs-new/public

USER nextjs

EXPOSE 3000

ENV PORT=3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
CMD ["node", "apps/docs-new/server.js"]