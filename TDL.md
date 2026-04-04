# Math Game — Technical Design List (TDL)

> Cross-platform mobile math game inspired by puzzle/word games like Խաչбառ.
> Target: React Native (iOS + Android) + Go (Fiber) backend + PostgreSQL.
> Date: 2026-04-04

---

## 1. Project Overview

A math puzzle game where players solve math problems across levels grouped by school grade and university. Players earn points, spend energy, unlock levels, and can challenge friends.

### Core Pillars
| Pillar | Description |
|--------|-------------|
| **Puzzle Mechanic** | Math crossword grid — equations run horizontally & vertically, shared cells must satisfy both |
| **Progression** | Tiers → Chapters → Levels; stars per level (1–3); 215 total levels |
| **Social** | Invite friends, weekly leaderboard, challenge mode (same puzzle seed) |
| **Engagement** | Energy system, daily crossword, streak, coins, hints |
| **Multilingual** | Armenian (հայ), English, Russian |

> Full crossword mechanic spec: `CROSSWORD_DESIGN.md`

---

## 2. Education Tiers & Level Structure

Each level = **one crossword puzzle**. Levels are grouped into chapters per tier.

```
Tier 1 — Grades 1–5  (2×2 / 3×2 grids, + and −)
  ├── Chapter 1: Addition          10 levels
  ├── Chapter 2: Subtraction       10 levels
  ├── Chapter 3: Mixed + −         10 levels
  ├── Chapter 4: Multiplication    10 levels
  └── Chapter 5: Division          10 levels
  TOTAL: 50 levels

Tier 2 — Grades 5–7  (3×3 / 4×3 grids, all 4 ops + %)
  ├── Chapter 1: Fractions         10 levels
  ├── Chapter 2: Percentages       10 levels
  ├── Chapter 3: Basic algebra     10 levels
  ├── Chapter 4: Mixed             10 levels
  └── Chapter 5: Speed rounds      10 levels
  TOTAL: 50 levels

Tier 3 — Grades 7–10  (4×4 / 5×4 grids, negatives, fractions)
  ├── Chapter 1: Linear equations  10 levels
  ├── Chapter 2: Quadratic results 10 levels
  ├── Chapter 3: Geometry values   10 levels
  ├── Chapter 4: Negative numbers  10 levels
  ├── Chapter 5: Mixed hard        15 levels
  └── Chapter 6: Challenge         5 levels
  TOTAL: 55 levels

Tier 4 — University  (5×5 / 6×5 grids, roots, log, trig, matrices)
  ├── Chapter 1: Powers & roots    10 levels
  ├── Chapter 2: Logarithms        10 levels
  ├── Chapter 3: Trig exact values 10 levels
  ├── Chapter 4: Combinatorics     10 levels
  ├── Chapter 5: Matrices          10 levels
  └── Chapter 6: Elite             10 levels
  TOTAL: 60 levels

GRAND TOTAL: 215 levels
```

Unlock rules: complete level N → unlock N+1; need ≥ 2★ avg to unlock next chapter; complete all chapters in a tier to unlock the next tier.

---

## 3. Puzzle Types

| ID | Name | Description | Example |
|----|------|-------------|---------|
| P1 | Fill the blank | `3 + ? = 7` | Tap correct number from options |
| P2 | Equation crossword | Math crossword grid (horizontal + vertical = clue) | Grid with 3×3 intersecting equations |
| P3 | Number chain | Connect numbers in order to reach a target sum | Tap sequence of cells |
| P4 | Missing operator | `4 ? 3 = 12` choose +, −, ×, ÷ | Multiple choice operator |
| P5 | True/False | `5 × 8 = 40` — True or False? | Quick-tap |
| P6 | Sort & order | Arrange fractions/numbers from least to greatest | Drag-and-drop |
| P7 | Word problem | Short math word problem with multiple choice | Reading + calc |
| P8 | Matrix puzzle | Fill missing cells in a 3×3 number grid (Tier 3+) | Logic deduction |

---

## 4. User Profile & Progression

### 4.1 Player Stats
```
- username
- avatar (preset selection)
- tier unlocked (1–4)
- current level per tier
- total score (XP)
- stars collected
- coins (soft currency)
- gems (hard currency, optional)
- energy (0–10, refills 1/30min)
- daily streak (days in a row played)
- achievements []
- friends []
- preferred language
```

### 4.2 Energy System
- Max energy: **10**
- Each puzzle attempt costs **1 energy**
- Regenerates **1 energy per 30 minutes**
- Can invite a friend to get **+3 energy** (once per friend, once per day)
- Watch ad (optional) → **+2 energy**
- Full refill via **gems** (premium)

### 4.3 Scoring
```
Per puzzle:
  - Correct on 1st try:  +100 XP + time bonus (up to +50)
  - Correct on 2nd try:  +50 XP
  - Correct on 3rd try:  +25 XP
  - Wrong / skip:        0 XP

Per level (10 puzzles):
  - 3 stars: 90–100% correct, < time limit
  - 2 stars: 60–89% correct
  - 1 star:  40–59% correct
  - 0 stars: < 40% (must retry)

Bonus XP:
  - Perfect level (10/10): +200 XP
  - Daily streak day 7: ×2 XP multiplier for 24h
  - First time clearing a tier: +500 XP
```

### 4.4 Leaderboard
- **Global** leaderboard by total XP
- **Friends** leaderboard
- **Tier-specific** leaderboard (e.g. best University math players)
- Resets weekly; top 3 get coin rewards

---

## 5. Social Features

### 5.1 Invite Friends
- Share via: SMS link, WhatsApp, Telegram, copy link
- Deep link: `mathgame://invite?ref=USER_ID`
- Invited friend registers → both get **+50 coins + 3 energy**
- Track referral chain (max 1 level deep)

### 5.2 Challenge Mode
- Player picks a level → sends challenge to friend
- Friend gets notification: "Armen challenged you on Level 12!"
- Both play same puzzle set (same seed), compare scores
- Winner gets **+30 coins**

### 5.3 Co-op Mode (Phase 2)
- Two players race to solve same puzzle in real-time
- First to answer wins the round; best of 5 rounds

---

## 6. Languages

| Code | Language | Status |
|------|----------|--------|
| `hy` | Armenian (հայ) | Primary |
| `en` | English | Secondary |
| `ru` | Russian | Secondary |

- All UI strings in i18n JSON files
- Math word problems authored in all 3 languages
- Language toggle in settings (persists to profile)
- Number formatting localized (decimal separator)

---

## 7. Tech Stack

### Frontend (Mobile)
| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x (Dart) |
| Navigation | go_router |
| State | Riverpod 2 |
| Animations | Flutter built-in — AnimationController, CustomPainter |
| HTTP | dio |
| i18n | flutter_localizations + ARB files (hy, en, ru) |
| Storage | shared_preferences + flutter_secure_storage |
| Push notifications | firebase_messaging |
| Deep links | app_links |

### Backend (Go + Fiber)
| Layer | Technology |
|-------|------------|
| Language | Go 1.22 |
| Framework | Fiber v2 |
| ORM | GORM |
| Database | PostgreSQL 16 |
| Auth | JWT (golang-jwt/jwt v5) |
| Migrations | golang-migrate |
| API style | REST JSON |
| Real-time | Fiber WebSocket (gorilla/websocket under the hood) |
| Cache | Redis (go-redis) — energy timers, leaderboard cache |
| Config | godotenv (.env) |

**Why Fiber:** Express-like routing, fastest Go HTTP framework (benchmarks), built-in WebSocket support for Phase 4 co-op mode.
**Why PostgreSQL:** JSONB for puzzle `data_json`/`answer_json`, native arrays, window functions for leaderboard rankings, better than MySQL for complex queries.

### Optional later
- Firebase FCM for push notifications (firebase_messaging)
- pgBouncer for connection pooling in production
- Flutter Web for browser-based play

---

## 8. Database Schema (Core Tables)

PostgreSQL — uses JSONB for flexible puzzle data, UUIDs as primary keys.

```sql
users               (id UUID PK, username TEXT UNIQUE, email TEXT UNIQUE, password_hash TEXT, language CHAR(2), avatar TEXT, created_at TIMESTAMPTZ)
user_stats          (user_id UUID FK, xp INT, coins INT, gems INT, energy INT, energy_updated_at TIMESTAMPTZ, streak INT, streak_last_date DATE)
tiers               (id SERIAL PK, name_hy TEXT, name_en TEXT, name_ru TEXT, min_grade INT, max_grade INT, sort_order INT)
levels              (id SERIAL PK, tier_id INT FK, number INT, title_hy TEXT, title_en TEXT, title_ru TEXT, unlock_xp_required INT)
puzzles             (id SERIAL PK, level_id INT FK, type TEXT, difficulty INT, data JSONB, answer JSONB, time_limit_sec INT)
user_level_progress (user_id UUID FK, level_id INT FK, stars INT, best_score INT, attempts INT, completed_at TIMESTAMPTZ, PRIMARY KEY (user_id, level_id))
user_puzzle_log     (id BIGSERIAL PK, user_id UUID FK, puzzle_id INT FK, is_correct BOOL, xp_earned INT, time_taken_ms INT, played_at TIMESTAMPTZ)
friendships         (id UUID PK, user_id UUID FK, friend_id UUID FK, status TEXT, created_at TIMESTAMPTZ)
referrals           (id UUID PK, referrer_id UUID FK, referred_id UUID FK, rewarded_at TIMESTAMPTZ)
challenges          (id UUID PK, challenger_id UUID FK, opponent_id UUID FK, level_id INT FK, seed BIGINT, status TEXT, created_at TIMESTAMPTZ)
challenge_scores    (id UUID PK, challenge_id UUID FK, user_id UUID FK, score INT, completed_at TIMESTAMPTZ)
leaderboard_weekly  (id UUID PK, user_id UUID FK, tier_id INT FK, xp_this_week INT, week_start DATE)
achievements        (id SERIAL PK, key TEXT UNIQUE, name_hy TEXT, name_en TEXT, name_ru TEXT, icon TEXT, condition JSONB)
user_achievements   (user_id UUID FK, achievement_id INT FK, earned_at TIMESTAMPTZ, PRIMARY KEY (user_id, achievement_id))
```

**JSONB puzzle example:**
```json
// data field for P1 (fill the blank): {"question": "3 + ? = 7", "options": [2, 4, 5, 7]}
// answer field:                        {"value": 4}

// data field for P2 (crossword): {"grid": [[3,"?",5],["+","+","+"],[2,1,"?"]], "clues": {...}}
// answer field:                   {"cells": {"0,1": 2, "2,2": 6}}
```

---

## 9. API Endpoints

```
Auth
  POST   /api/auth/register
  POST   /api/auth/login
  POST   /api/auth/refresh
  GET    /api/auth/me

Profile
  GET    /api/profile
  PATCH  /api/profile          (language, avatar, username)

Game
  GET    /api/tiers             (list tiers)
  GET    /api/tiers/{id}/levels (levels in tier)
  GET    /api/levels/{id}/puzzles
  POST   /api/puzzles/{id}/submit  {answer, time_ms}
  GET    /api/progress           (user's progress across all tiers)

Social
  GET    /api/friends
  POST   /api/friends/invite     (generate invite link)
  POST   /api/friends/add        {ref_code}
  GET    /api/leaderboard?tier=&scope=global|friends
  POST   /api/challenges          (create challenge)
  POST   /api/challenges/{id}/accept
  POST   /api/challenges/{id}/complete

Energy
  GET    /api/energy
  POST   /api/energy/refill      (spend gems)

Achievements
  GET    /api/achievements
```

---

## 10. Screens (Mobile App)

```
App
├── Onboarding
│   ├── SplashScreen
│   ├── LanguageSelectScreen
│   └── OnboardingCarouselScreen
├── Auth
│   ├── LoginScreen
│   └── RegisterScreen
├── Main (Tab Navigator)
│   ├── HomeScreen           — daily challenge, streak, quick play
│   ├── TiersScreen          — 4 tier cards (grade groups)
│   │   └── LevelsScreen     — level map / grid for selected tier
│   │       └── PuzzleScreen — active puzzle gameplay
│   │           └── LevelCompleteScreen — stars + XP earned
│   ├── LeaderboardScreen    — global / friends / tier tabs
│   ├── FriendsScreen        — friends list, invite, challenge
│   └── ProfileScreen        — stats, achievements, settings
└── Modals
    ├── EnergyModal          — out of energy prompt
    ├── ChallengeInviteModal — incoming challenge notification
    └── AchievementUnlockModal
```

---

## 11. Puzzle Content Plan

### Tier 1 sample (Grade 1–5)
- Level 1–10: Addition/subtraction within 20
- Level 11–20: Multiplication tables (2–5)
- Level 21–30: Division, mixed operations
- Level 31–40: Simple fractions, ordering numbers

### Tier 4 sample (University)
- Level 1–10: Limits (fill the blank: lim x→0 sin(x)/x = ?)
- Level 11–20: Derivatives (match function to derivative)
- Level 21–30: Integrals (choose correct integral)
- Level 31–40: Matrix operations
- Level 41–50: Combinatorics, probability problems

---

## 12. Phase Roadmap

### Phase 1 — MVP (Months 1–2)
- [ ] Backend: auth, tiers, levels, puzzles, submit answer, score
- [ ] Mobile: Onboarding, Auth, Tier/Level map, Puzzle screen, Profile
- [ ] Puzzle types: P1, P4, P5 (simple tap puzzles)
- [ ] Language: Armenian only
- [ ] 2 tiers (Grade 1–5, Grade 5–7), 20 levels each, 200 puzzles
- [ ] Local energy system (no refill via social yet)

### Phase 2 — Social (Month 3)
- [ ] Friends system + invite links
- [ ] Challenge mode
- [ ] Leaderboard (weekly reset)
- [ ] Language: add English, Russian
- [ ] Energy refill via friend invite
- [ ] Push notifications (challenges, energy full)

### Phase 3 — Content & Polish (Month 4)
- [ ] Tiers 3 & 4 (Grade 7–10, University)
- [ ] Puzzle types P2 (crossword grid), P3, P6, P7
- [ ] Achievements system
- [ ] Daily streak rewards
- [ ] Animations and sound effects
- [ ] App Store / Play Store submission prep

### Phase 4 — Monetization (Month 5+)
- [ ] Gem purchase (in-app purchase)
- [ ] Energy full refill
- [ ] Optional rewarded ads
- [ ] Co-op real-time mode (WebSocket)

---

## 13. Decided / Open Questions

| # | Question | Decision |
|---|----------|----------|
| 1 | Backend language | **Go 1.22** |
| 2 | Go HTTP framework | **Fiber v2** |
| 3 | Database | **PostgreSQL 16** |
| 4 | Auth | JWT — Google/Apple sign-in TBD |
| 5 | Puzzle authoring | **TBD** — hand-authored JSON vs algorithm-generated |
| 6 | Real-time (co-op) | **Fiber WebSocket** (Phase 4) |
| 7 | Push notifications | **TBD** — Firebase FCM or Expo push |
| 8 | Monetization | **TBD** — free with ads or premium tiers |
| 9 | App name & branding | **TBD** |
| 10 | Offline mode | **TBD** — cache puzzles in AsyncStorage? |

---

## 14. Immediate Next Steps

1. Resolve open TBD items (puzzle authoring, app name)
2. `mkdir backend && go mod init math-game` — scaffold Fiber app
3. Write PostgreSQL migrations (core tables)
4. Implement auth endpoints (register, login, refresh, me)
5. Seed Tier 1 Chapter 1 puzzles (10 crosswords as JSONB)
6. `flutter create math_game` — scaffold Flutter app
7. Add go_router navigation + ARB i18n (hy/en/ru)
8. Build crossword grid widget with CustomPainter
9. Wire puzzle screen to backend API via dio
