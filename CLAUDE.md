# CLAUDE.md — Math Game

## What this project is
A math crossword puzzle mobile game (inspired by Խաչбառ) for the Armenian market.
iOS + Android via Flutter. Go backend. PostgreSQL database.

## Session memory rule
- Read `memory/MEMORY.md` for index at session start
- Read latest session file for full context
- Write session file + update MEMORY.md index at session end

## Stack
| Layer | Technology |
|-------|------------|
| Mobile | Flutter 3.x (Dart) |
| Navigation | go_router |
| State | Riverpod 2 |
| HTTP | dio |
| i18n | flutter_localizations + ARB (hy, en, ru) |
| Backend | Go 1.22 + Fiber v2 + GORM |
| Database | PostgreSQL 16 |
| Migrations | golang-migrate |
| Auth | JWT (golang-jwt/jwt v5) |
| Cache | Redis |

## Project structure (planned)
```
math-game/
├── backend/          ← Go + Fiber API server
│   ├── cmd/server/   ← main.go entry point
│   ├── internal/
│   │   ├── handler/  ← Fiber route handlers
│   │   ├── service/  ← business logic
│   │   ├── model/    ← GORM models
│   │   └── middleware/
│   ├── migrations/   ← golang-migrate SQL files
│   └── .env.example
├── mobile/           ← Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── router/
│   │   ├── features/
│   │   │   ├── crossword/  ← crossword grid widget (CustomPainter)
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── tiers/
│   │   │   └── profile/
│   │   ├── l10n/           ← ARB files (hy, en, ru)
│   │   └── shared/
│   └── pubspec.yaml
├── memory/           ← session memory files
├── TDL.md            ← technical design list
├── CROSSWORD_DESIGN.md ← crossword mechanic spec
└── CLAUDE.md         ← this file
```

## Design docs
- `TDL.md` — full technical design (tiers, levels, scoring, API, DB schema)
- `CROSSWORD_DESIGN.md` — crossword grid mechanic, JSONB format, level structure

## Key rules
- Never commit `.env` — use `.env.example`
- Puzzle data stored as JSONB in PostgreSQL
- All UI strings must have hy/en/ru translations in ARB files
- Crossword grid drawn with Flutter `CustomPainter` — no third-party grid libs
- Run Code Review checklist before every push (no secrets, no debug logs)

## Current phase
**Phase 1 MVP** — not yet started.
Next: scaffold `backend/` then `mobile/`.
