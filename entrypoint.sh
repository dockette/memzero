#!/bin/bash
set -Eeo pipefail

echo "Memzero (mem0 ${MEM0_VERSION})"

printf "\n\n"

echo "MEM0 ============================="
echo "PORT=${PORT}"
echo "WORKERS=${WORKERS:-1}"
echo "HISTORY_DB_PATH=${HISTORY_DB_PATH}"
echo "DASHBOARD_URL=${DASHBOARD_URL}"
echo "AUTH_DISABLED=${AUTH_DISABLED}"
echo "MEM0_TELEMETRY=${MEM0_TELEMETRY}"
echo "MEM0_DEFAULT_LLM_MODEL=${MEM0_DEFAULT_LLM_MODEL:-<default>}"
echo "MEM0_DEFAULT_EMBEDDER_MODEL=${MEM0_DEFAULT_EMBEDDER_MODEL:-<default>}"

printf "\n\n"

echo "POSTGRES ========================="
echo "POSTGRES_HOST=${POSTGRES_HOST}"
echo "POSTGRES_PORT=${POSTGRES_PORT}"
echo "POSTGRES_DB=${POSTGRES_DB}"
echo "POSTGRES_USER=${POSTGRES_USER}"
echo "POSTGRES_COLLECTION_NAME=${POSTGRES_COLLECTION_NAME}"
echo "APP_DB_NAME=${APP_DB_NAME}"

printf "\n\n"

echo "MIGRATIONS ======================="
if [[ -z "${SKIP_MIGRATIONS}" ]]; then
    for i in $(seq 1 "${MIGRATIONS_RETRIES:-30}"); do
        if alembic upgrade head; then
            break
        fi

        if [[ "${i}" == "${MIGRATIONS_RETRIES:-30}" ]]; then
            echo "Migrations failed, giving up after ${i} attempts"
            exit 1
        fi

        echo "Migrations failed (attempt ${i}), database not ready? Retrying in 2s..."
        sleep 2
    done
else
    echo "Skipped"
fi

printf "\n\n"

mkdir -p "$(dirname "${HISTORY_DB_PATH}")"

exec uvicorn main:app \
    --host 0.0.0.0 \
    --port "${PORT}" \
    --workers "${WORKERS:-1}" \
    ${UVICORN_ARGS}
