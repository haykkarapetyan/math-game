---
name: Project Overview
description: Core stack decisions, game concept, and current phase for the math game project
type: project
---

# Math Game — Project Overview

## Concept
A math crossword puzzle mobile game (inspired by Խաչбառ) for the Armenian market.
Players solve arithmetic crossword grids where equations run horizontally and vertically,
shared cells must satisfy both equations simultaneously.

## Stack (confirmed)
- **Mobile:** Flutter 3.x (Dart) — go_router, Riverpod 2, CustomPainter for grid
- **Backend:** Go 1.22 + Fiber v2 + GORM
- **Database:** PostgreSQL 16 (JSONB for puzzle data)
- **Migrations:** golang-migrate
- **Auth:** JWT (golang-jwt/jwt v5)
- **Cache:** Redis (energy timers, leaderboard)
- **i18n:** ARB files — Armenian (hy), English (en), Russian (ru)

## Game Structure
- 4 tiers: Grades 1–5, Grades 5–7, Grades 7–10, University
- Each tier has chapters, each chapter has levels
- Each level = one crossword puzzle
- 215 total levels
- Grid sizes: 2×2 (Tier 1) → 6×5 (Tier 4)

## Key Design Files
- `TDL.md` — full technical design list
- `CROSSWORD_DESIGN.md` — crossword mechanic spec, grid anatomy, level structure, JSONB format

## Current Phase
Phase 1 MVP — not yet started. Next steps:
1. Scaffold Go backend (`backend/`)
2. PostgreSQL migrations
3. Auth endpoints
4. Seed Tier 1 Chapter 1 puzzles
5. `flutter create math_game` — scaffold Flutter app
6. Build crossword grid widget with CustomPainter

## GitHub
https://github.com/haykkarapetyan/math-game

**Why:** Fastest to ship cross-platform (iOS + Android). Flutter's CustomPainter is ideal
for drawing the crossword grid. Go + Fiber for high-concurrency API.
