CREATE TABLE puzzles (
    id SERIAL PRIMARY KEY,
    level_id INT NOT NULL REFERENCES levels(id),
    type TEXT NOT NULL DEFAULT 'crossword',
    difficulty INT NOT NULL DEFAULT 1,
    data JSONB NOT NULL,
    answer JSONB NOT NULL,
    time_limit_sec INT NOT NULL DEFAULT 120
);

CREATE INDEX idx_puzzles_level_id ON puzzles(level_id);
