# ---------------------------
# Stage 1: Builder
# ---------------------------
FROM oven/bun:latest AS builder

WORKDIR /app

COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile

COPY . .

# Generate Prisma client with placeholder environment variables to avoid build failures
ENV DATABASE_URL="postgresql://placeholder:placeholder@placeholder:5432/placeholder"
ENV DIRECT_URL="postgresql://placeholder:placeholder@placeholder:5432/placeholder"
RUN bunx prisma generate

# ---------------------------
# Stage 2: Runtime
# ---------------------------
FROM oven/bun:latest AS runtime

WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 ruparupa && \
    adduser --system --uid 1001 --ingroup ruparupa ruparupa

# Copy only built assets and node_modules
COPY --from=builder /app /app

# Change ownership to the non-root user before switching to it
RUN chown -R ruparupa:ruparupa /app

USER ruparupa

ENV NODE_ENV=production
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ping || exit 1

# Create the start script with proper permissions before switching to non-root user
USER root
RUN echo '#!/bin/sh\nset -e\n\nif [ "$DATABASE_MIGRATE_ON_START" = "true" ]; then\n  echo "Running database migrations..."\n  bunx prisma db push --accept-data-loss || echo "Database migration failed"\nfi\n\necho "Starting application..."\nbun run src/index.ts' > /app/start.sh && chmod +x /app/start.sh
RUN chown ruparupa:ruparupa /app/start.sh

USER ruparupa

CMD ["sh", "./start.sh"]
