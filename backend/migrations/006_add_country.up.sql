ALTER TABLE users ADD COLUMN country CHAR(2) NOT NULL DEFAULT '';
CREATE INDEX idx_users_country ON users(country);
