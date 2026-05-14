-- Money Manager App — Database Schema
-- Run this to drop old tables and create fresh ones

DROP TABLE IF EXISTS sync_metadata CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS people CASCADE;
DROP TABLE IF EXISTS stat_entries CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
  id UUID PRIMARY KEY,
  pin_hash TEXT NOT NULL,
  last_login TIMESTAMPTZ
);

INSERT INTO users (id, pin_hash) VALUES ('00000000-0000-0000-0000-000000000000', '1965'); -- Placeholder, will be hashed later or used as is for now as per "seed the pin '1965'"

CREATE TABLE tags (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  color VARCHAR(7) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  type VARCHAR(10) NOT NULL CHECK (type IN ('income', 'outgoing')),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  amount DECIMAL(12,2) NOT NULL,
  tag_id UUID REFERENCES tags(id),
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE stat_entries (
  id UUID PRIMARY KEY,
  card_type VARCHAR(20) NOT NULL CHECK (card_type IN ('assets','liabilities','income','expenses')),
  name VARCHAR(255) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE people (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE loans (
  id UUID PRIMARY KEY,
  person_id UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL,
  type VARCHAR(10) NOT NULL CHECK (type IN ('given','taken')),
  description TEXT,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sync_metadata (
  id UUID PRIMARY KEY,
  record_id UUID NOT NULL,
  record_type VARCHAR(50) NOT NULL,
  last_modified TIMESTAMPTZ NOT NULL,
  is_deleted BOOLEAN DEFAULT FALSE,
  version INTEGER DEFAULT 1
);

CREATE INDEX idx_sync_record ON sync_metadata(record_id, record_type);
