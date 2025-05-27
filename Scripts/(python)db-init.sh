#!/usr/bin/env python3

import os
import psycopg2
from pymongo import MongoClient
from pymongo.errors import OperationFailure

db_type = os.getenv("DB_TYPE", "postgresql")

if db_type == "postgresql":
    try:
        print("🔧 Connecting to PostgreSQL...")
        conn = psycopg2.connect(
            host=os.getenv("POSTGRES_HOST"),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD"),
            port=os.getenv("POSTGRES_PORT", "5432")
        )
        conn.autocommit = True  # Enable autocommit for database creation
        with conn.cursor() as cursor:
            db_name = os.getenv("POSTGRES_DB")
            cursor.execute(f"SELECT 1 FROM pg_database WHERE datname = '{db_name}';")
            if not cursor.fetchone():
                cursor.execute(f"CREATE DATABASE {db_name};")
            cursor.execute(f"ALTER DATABASE {db_name} OWNER TO {os.getenv('POSTGRES_USER')};")
            print(f"✅ PostgreSQL database '{db_name}' initialized.")
        conn.close()
    except Exception as e:
        print(f"❌ PostgreSQL init failed: {e}")

elif db_type == "mongodb":
    try:
        print("🔧 Connecting to MongoDB...")
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client[os.getenv("MONGO_DB")]
        db.command("createUser", os.getenv("MONGO_USER"), pwd=os.getenv("MONGO_PASSWORD"),
                   roles=[{"role": "readWrite", "db": os.getenv("MONGO_DB")}])
        print(f"✅ MongoDB database '{os.getenv('MONGO_DB')}' initialized.")
    except OperationFailure as e:
        print(f"❌ MongoDB user already exists or error: {e}")
    except Exception as e:
        print(f"❌ MongoDB init failed: {e}")
else:
    print(f"❌ Unsupported DB_TYPE: {db_type}")
