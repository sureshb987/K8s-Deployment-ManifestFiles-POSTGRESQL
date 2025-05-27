#!/bin/bash

set -e

echo "🔧 Starting database initialization..."

if [[ "$DB_TYPE" == "postgresql" ]]; then
  echo "⚙️  Initializing PostgreSQL database..."
  PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -p "${POSTGRES_PORT:-5432}" <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$POSTGRES_DB') THEN
      CREATE DATABASE $POSTGRES_DB;
   END IF;
END \$\$;
ALTER DATABASE $POSTGRES_DB OWNER TO $POSTGRES_USER;
EOF

elif [[ "$DB_TYPE" == "mongodb" ]]; then
  echo "⚙️  Initializing MongoDB database..."
  mongosh "$MONGO_URI" --eval "
    db = db.getSiblingDB('$MONGO_DB');
    db.createUser({
      user: '$MONGO_USER',
      pwd: '$MONGO_PASSWORD',
      roles: [{ role: 'readWrite', db: '$MONGO_DB' }]
    });
  "
else
  echo "❌ Unsupported DB_TYPE: $DB_TYPE"
  exit 1
fi

echo "✅ Database initialization complete!"
