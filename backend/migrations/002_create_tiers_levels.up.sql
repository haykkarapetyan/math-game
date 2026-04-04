CREATE TABLE tiers (
    id SERIAL PRIMARY KEY,
    name_hy TEXT NOT NULL,
    name_en TEXT NOT NULL,
    name_ru TEXT NOT NULL,
    min_grade INT NOT NULL,
    max_grade INT NOT NULL,
    sort_order INT NOT NULL
);

CREATE TABLE levels (
    id SERIAL PRIMARY KEY,
    tier_id INT NOT NULL REFERENCES tiers(id),
    number INT NOT NULL,
    title_hy TEXT NOT NULL DEFAULT '',
    title_en TEXT NOT NULL DEFAULT '',
    title_ru TEXT NOT NULL DEFAULT '',
    unlock_xp_required INT NOT NULL DEFAULT 0,
    UNIQUE(tier_id, number)
);
