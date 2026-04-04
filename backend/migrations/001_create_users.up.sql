CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    language CHAR(2) NOT NULL DEFAULT 'hy',
    avatar TEXT NOT NULL DEFAULT 'fox',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    xp INT NOT NULL DEFAULT 0,
    coins INT NOT NULL DEFAULT 100,
    gems INT NOT NULL DEFAULT 0,
    energy INT NOT NULL DEFAULT 10,
    energy_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    streak INT NOT NULL DEFAULT 0,
    streak_last_date DATE
);
