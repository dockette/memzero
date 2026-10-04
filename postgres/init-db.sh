#!/bin/bash
set -e

# Create the app database for user/auth/api-key data.
# The POSTGRES_DB database is used by pgvector for memory storage.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE ${APP_DB_NAME:-mem0_app}'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${APP_DB_NAME:-mem0_app}')\gexec
EOSQL
