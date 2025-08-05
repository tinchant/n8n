#!/bin/bash
set -e

# Script de inicialização do PostgreSQL para n8n
echo "Inicializando banco de dados PostgreSQL para n8n..."

# Criar usuário não-root se especificado
if [ "$POSTGRES_NON_ROOT_USER" ] && [ "$POSTGRES_NON_ROOT_PASSWORD" ]; then
    echo "Criando usuário não-root: $POSTGRES_NON_ROOT_USER"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $POSTGRES_NON_ROOT_USER WITH PASSWORD '$POSTGRES_NON_ROOT_PASSWORD';
        GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_NON_ROOT_USER;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $POSTGRES_NON_ROOT_USER;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_NON_ROOT_USER;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $POSTGRES_NON_ROOT_USER;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $POSTGRES_NON_ROOT_USER;
EOSQL
fi


# Criar banco evolution se não existir
if [ "$EVOLUTION_DB" ]; then
    echo "Criando banco de dados para Evolution: $EVOLUTION_DB"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
        DO $$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$EVOLUTION_DB') THEN
                CREATE DATABASE "$EVOLUTION_DB";
            END IF;
        END
        $$;
EOSQL
fi

# Configurar extensões úteis para ambos bancos
for DB in "$POSTGRES_DB" "$EVOLUTION_DB"; do
  if [ "$DB" ]; then
    echo "Configurando extensões do PostgreSQL em $DB..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB" <<-EOSQL
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE EXTENSION IF NOT EXISTS "pg_trgm";
EOSQL
  fi
done

echo "Inicialização do PostgreSQL concluída!"

