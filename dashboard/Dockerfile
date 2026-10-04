# VERSIONS #####################################################################
ARG MEM0_VERSION=2.2.1

FROM node:20-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# SOURCES ######################################################################
FROM base AS source

ARG MEM0_VERSION

RUN apk add --no-cache curl tar && \
    curl -f -L https://github.com/mem0ai/mem0/archive/refs/tags/v${MEM0_VERSION}.tar.gz -o /tmp/mem0.tar.gz && \
    tar -xzf /tmp/mem0.tar.gz -C /tmp && \
    cp -a /tmp/mem0-${MEM0_VERSION}/server/dashboard/. /app/ && \
    rm -rf /tmp/mem0.tar.gz /tmp/mem0-${MEM0_VERSION} /app/node_modules /app/.next

# BUILD ########################################################################
FROM base AS builder

COPY --from=source /app /app

ENV NEXT_TELEMETRY_DISABLED=1
# Placeholder values replaced at runtime by entrypoint.sh
ENV NEXT_PUBLIC_API_URL=NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_INSTANCE_NAME=NEXT_PUBLIC_INSTANCE_NAME

RUN corepack enable pnpm && \
    pnpm install && \
    pnpm build

# RUNTIME ######################################################################
FROM base AS runner

ARG MEM0_VERSION
ENV MEM0_VERSION=${MEM0_VERSION}

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/entrypoint.sh /home/nextjs/entrypoint.sh
RUN chmod 755 /home/nextjs/entrypoint.sh

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV NEXT_PUBLIC_API_URL=http://localhost:8888
ENV NEXT_PUBLIC_INSTANCE_NAME=Memzero

ENTRYPOINT ["/home/nextjs/entrypoint.sh"]
CMD ["node", "server.js"]
