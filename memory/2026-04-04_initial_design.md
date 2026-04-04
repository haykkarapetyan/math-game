---
name: Initial Design Session
description: Session where full TDL, crossword mechanic, and stack were decided
type: project
---

# Session 2026-04-04 — Initial Design

## What was done
- Created `TDL.md` — full technical design list covering game concept, tiers, levels,
  puzzle types, user profile, energy system, scoring, social features, API endpoints,
  DB schema, screen map, and phase roadmap
- Created `CROSSWORD_DESIGN.md` — detailed crossword mechanic spec including:
  - Grid anatomy (number cells, operator cells, result cells)
  - Grid sizes per tier (2×2 → 6×5)
  - Full level structure: 4 tiers × chapters × levels = 215 total levels
  - Star rating system (★★★ = no mistakes + under time limit)
  - Input UX: multiple choice (Tier 1–2) vs number pad (Tier 3–4)
  - Hints system (3 hints per level, reveal/check/clue)
  - Daily crossword (same puzzle for all players, no energy cost)
  - JSONB puzzle data format with example
  - Difficulty scaling levers

## Stack decisions made
- Backend: Go 1.22 + Fiber v2 + GORM + PostgreSQL 16 (not PHP/MySQL)
- Mobile: Flutter 3.x (not React Native — better CustomPainter for crossword grid)
- iOS + Android both required → Flutter chosen over Kotlin

## Open items
- Puzzle authoring: hand-written JSON vs auto-generated algorithm — TBD
- App name in Armenian — TBD
- Offline mode (cache puzzles in shared_preferences?) — TBD
- Auth: JWT only or also Google/Apple sign-in? — TBD
- Monetization model — TBD

## Next session should start with
1. Scaffold `backend/` — Go + Fiber + GORM
2. Write PostgreSQL migrations
3. Auth endpoints (register, login, refresh, me)
4. Seed 10 crossword puzzles for Tier 1 Chapter 1
5. `flutter create math_game` in `mobile/`
