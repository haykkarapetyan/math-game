CREATE TABLE user_level_progress (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    level_id INT NOT NULL REFERENCES levels(id),
    stars INT NOT NULL DEFAULT 0,
    best_score INT NOT NULL DEFAULT 0,
    attempts INT NOT NULL DEFAULT 0,
    completed_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, level_id)
);

CREATE TABLE user_puzzle_log (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    puzzle_id INT NOT NULL REFERENCES puzzles(id),
    is_correct BOOL NOT NULL DEFAULT false,
    xp_earned INT NOT NULL DEFAULT 0,
    time_taken_ms INT NOT NULL DEFAULT 0,
    played_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_puzzle_log_user ON user_puzzle_log(user_id);
