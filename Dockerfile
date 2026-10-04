FROM python:3.12-slim

# VERSIONS #####################################################################
ARG MEM0_VERSION=2.2.1
ENV MEM0_VERSION=${MEM0_VERSION}

WORKDIR /app

# DEPENDENCIES #################################################################
RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        libpq5 && \
    rm -rf /var/lib/apt/lists/*

# MEM0 SERVER ##################################################################
RUN curl -f -L https://github.com/mem0ai/mem0/archive/refs/tags/v${MEM0_VERSION}.tar.gz -o /tmp/mem0.tar.gz && \
    tar -xzf /tmp/mem0.tar.gz -C /tmp && \
    cp -a /tmp/mem0-${MEM0_VERSION}/server/. /app/ && \
    rm -rf /tmp/mem0.tar.gz /tmp/mem0-${MEM0_VERSION}

RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /app/history

# CONFIGURATION ################################################################
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000 \
    HISTORY_DB_PATH=/app/history/history.db \
    POSTGRES_HOST=postgres \
    POSTGRES_PORT=5432 \
    POSTGRES_DB=postgres \
    POSTGRES_USER=postgres \
    POSTGRES_COLLECTION_NAME=memories \
    APP_DB_NAME=mem0_app \
    DASHBOARD_URL=http://localhost:3000 \
    AUTH_DISABLED=false \
    MEM0_TELEMETRY=false

EXPOSE 8000

VOLUME /app/history

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
CMD ["/entrypoint.sh"]
