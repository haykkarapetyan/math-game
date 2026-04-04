# Math Crossword — Detailed Design

> The core game mechanic. An arithmetic crossword where equations run
> horizontally and vertically through a shared grid of numbers.
> Updated: 2026-04-04

---

## 1. How It Works

Unlike a word crossword, cells contain **numbers** and **operators**.
Horizontal rows and vertical columns form equations. The player fills in
the **blank (?) cells** so that every equation is satisfied.

```
Example 3×3 crossword (Tier 1):

    [3] [+] [?] = 5
     ×       +
    [?] [+] [2] = 7
     =       =
     6       ?

Rules:
  Row 1:  3 +  ? = 5   → ? = 2
  Row 2:  ? +  2 = 7   → ? = 5
  Col 1:  3 ×  ? = 6   → ? = 2  (same cell as Row 2 Col 1, confirms ✓)
  Col 2:  2 +  2 = ?   → ? = 4  (result cell, also fillable)
```

The key constraint: **a cell shared by a row and a column must satisfy both equations simultaneously.** This is what makes it a crossword, not just a list of equations.

---

## 2. Grid Anatomy

```
┌──────┬──────┬──────┬──────┬──────┐
│  N   │  OP  │  N   │  OP  │  N   │  ← number/operator cells
├──────┼──────┼──────┼──────┼──────┤
│  OP  │      │  OP  │      │  OP  │  ← operator row (vertical ops)
├──────┼──────┼──────┼──────┼──────┤
│  N   │  OP  │  N   │  OP  │  N   │
├──────┼──────┼──────┼──────┼──────┤
│  =   │      │  =   │      │  =   │
├──────┼──────┼──────┼──────┼──────┤
│  R   │      │  R   │      │  R   │  ← row/col result cells
└──────┴──────┴──────┴──────┴──────┘

Cell types:
  N  = number cell (given or blank ?)
  OP = operator cell (always given: +, −, ×, ÷)
  =  = equals sign (decorative)
  R  = result cell (given or blank ?)
```

For a **2-equation × 2-equation** grid (simplest):
- 4 number cells (2×2 values)
- 4 operator cells (2 horizontal + 2 vertical)
- 4 result cells (2 row results + 2 col results)
- Total interactive cells: up to 8 blanks, but typically 2–4 are hidden

---

## 3. Grid Sizes by Tier

| Tier | Grades | Grid | Equations | Max blanks | Example ops |
|------|--------|------|-----------|------------|-------------|
| 1 | 1–5 | 2×2 | 2H + 2V | 2–3 | + − |
| 1 | 1–5 | 3×2 | 3H + 2V | 3–4 | + − |
| 2 | 5–7 | 3×3 | 3H + 3V | 4–5 | + − × ÷ |
| 2 | 5–7 | 4×3 | 4H + 3V | 5–6 | + − × ÷ % |
| 3 | 7–10 | 4×4 | 4H + 4V | 6–8 | mixed + parentheses |
| 3 | 7–10 | 5×4 | 5H + 4V | 7–9 | fractions, negative nums |
| 4 | University | 5×5 | 5H + 5V | 8–12 | algebra, roots, powers |
| 4 | University | 6×5 | 6H + 5V | 10–14 | log, trig values, matrices |

Grid notation `R×C` = R number rows × C number columns.

---

## 4. Level Structure

Each tier has **chapters**, each chapter has **levels**, each level is **one crossword puzzle**.

```
Tier 1 — Grades 1–5
├── Chapter 1: Addition (10 levels, 2×2 grid, only +)
├── Chapter 2: Subtraction (10 levels, 2×2 grid, only −)
├── Chapter 3: Mixed + − (10 levels, 3×2 grid)
├── Chapter 4: Multiplication intro (10 levels, 2×2 grid, × and +)
└── Chapter 5: Division intro (10 levels, 3×2 grid, all 4 ops)
Total: 50 levels

Tier 2 — Grades 5–7
├── Chapter 1: Fractions (10 levels, 3×3 grid)
├── Chapter 2: Percentages (10 levels, 3×3 grid)
├── Chapter 3: Basic algebra (10 levels, 3×3 grid, one variable)
├── Chapter 4: Mixed difficulty (10 levels, 4×3 grid)
└── Chapter 5: Speed rounds (10 levels, 3×3 grid, tight time limit)
Total: 50 levels

Tier 3 — Grades 7–10
├── Chapter 1: Linear equations (10 levels, 4×4 grid)
├── Chapter 2: Quadratic results (10 levels, 4×4 grid)
├── Chapter 3: Geometry values (10 levels, 4×4 grid, π, areas)
├── Chapter 4: Negative numbers (10 levels, 5×4 grid)
├── Chapter 5: Mixed hard (15 levels, 5×4 grid)
└── Chapter 6: Challenge (5 levels, 5×5 grid, timed)
Total: 55 levels

Tier 4 — University
├── Chapter 1: Powers & roots (10 levels, 5×5 grid)
├── Chapter 2: Logarithms (10 levels, 5×5 grid)
├── Chapter 3: Trig exact values (10 levels, 5×5 grid)
├── Chapter 4: Combinatorics (10 levels, 6×5 grid)
├── Chapter 5: Matrices (10 levels, special grid format)
└── Chapter 6: Elite (10 levels, 6×5 grid, all topics)
Total: 60 levels

GRAND TOTAL: 215 levels
```

---

## 5. Level Unlock Rules

```
Within a chapter:   complete level N to unlock level N+1
Between chapters:   earn ≥ 2 stars avg in previous chapter
Between tiers:      complete all chapters in previous tier (≥ 1 star each)

Star rating per level:
  ★★★  Solved with 0 mistakes, within time limit
  ★★☆  Solved with 1–2 mistakes OR exceeded time limit
  ★☆☆  Solved with 3+ mistakes (any time)
  ✗    Failed (gave up or too many wrong attempts → replay required)
```

---

## 6. Puzzle Input UX

### Option A — Number Pad (recommended)
- Tap a blank cell → it highlights (Flutter: `GestureDetector` + `CustomPainter` redraws selected cell)
- Number pad slides up (0–9, decimal, negative, clear, confirm) — custom `BottomSheet` widget
- Wrong answer: cell shakes (`AnimationController` shake tween) + flashes red
- Correct answer: cell fills with green flash (`ColorTween`), locks in

### Option B — Multiple Choice (easier tiers)
- Tap a blank cell → 4 option bubbles appear around it (`Overlay` or `Stack` positioned widgets)
- Tap the correct number
- Used in Tier 1 to reduce friction for young players

### Flutter implementation note
The entire crossword grid is one `CustomPainter` widget — draws grid lines, cell values,
highlights, and result labels. Tap detection uses `GestureDetector` with hit-test math to
map tap position → grid cell coordinates.

### Adaptive rule:
- Tier 1–2: default to Option B (multiple choice)
- Tier 3–4: default to Option A (number pad)
- User can toggle in settings: "Use multiple choice hints"

---

## 7. Hints System

Each level has **3 hints** by default (refill costs coins).

| Hint type | Cost | Effect |
|-----------|------|--------|
| Reveal one cell | 1 hint | Shows the answer for one selected blank |
| Check my answer | 1 hint | Highlights all currently filled cells as ✓/✗ without penalty |
| Show equation clue | 1 hint | Highlights which equation a blank belongs to, shows partial working |

Hints do NOT reduce star rating, but using > 0 hints blocks the ★★★ "perfect" achievement.

---

## 8. Daily Crossword

A special free puzzle available every day:
- One crossword per day, same for all players (seeded by date)
- No energy cost
- Appears on HomeScreen with countdown to next day
- Leaderboard: fastest solve time globally
- Reward: +50 coins + streak day increment

---

## 9. Timed Mode vs Relaxed Mode

| Mode | Timer | Penalty | Target |
|------|-------|---------|--------|
| **Relaxed** | Shown but doesn't count | None | Casual / learning |
| **Timed** | Counts down | No ★★★ if over limit | Competitive |
| **Speed Run** | Counts UP (record time) | — | Leaderboard |

Default is Relaxed for Tiers 1–2, Timed for Tiers 3–4.
User can toggle per session.

---

## 10. Puzzle Data Format (JSONB in PostgreSQL)

```json
{
  "grid_rows": 3,
  "grid_cols": 3,
  "cells": [
    {"row": 0, "col": 0, "type": "number", "value": 3,    "given": true},
    {"row": 0, "col": 1, "type": "op",     "value": "+",  "given": true},
    {"row": 0, "col": 2, "type": "number", "value": null, "given": false},
    {"row": 1, "col": 0, "type": "op",     "value": "×",  "given": true},
    {"row": 1, "col": 2, "type": "op",     "value": "+",  "given": true},
    {"row": 2, "col": 0, "type": "number", "value": null, "given": false},
    {"row": 2, "col": 1, "type": "op",     "value": "+",  "given": true},
    {"row": 2, "col": 2, "type": "number", "value": 2,    "given": true}
  ],
  "row_results": [5, 7],
  "col_results": [null, 4],
  "time_limit_sec": 120,
  "hint_count": 3
}
```

Answer format:
```json
{
  "cells": [
    {"row": 0, "col": 2, "value": 2},
    {"row": 2, "col": 0, "value": 5}
  ],
  "col_results": [
    {"col": 1, "value": 4}
  ]
}
```

---

## 11. Difficulty Scaling Within a Level

As chapters progress, the generator/author uses these levers:

1. **Grid size** — bigger grid = more constraints = harder
2. **Number of blanks** — more blanks = harder
3. **Blank position** — blanks at intersections are hardest (must satisfy 2 equations)
4. **Operator variety** — only `+` → all 4 ops → mixed with fractions
5. **Number range** — 1–10 → 1–100 → negatives → decimals → irrational (π, √2)
6. **Time limit** — tighter limit increases pressure
7. **Result visibility** — hide row/col results for extra difficulty

---

## 12. Crossword vs Other Puzzle Types

The crossword is the **primary mechanic**. Other puzzle types (P1, P4, P5 etc. from TDL)
can appear as:
- **Warm-up** before a crossword level (30-second mini puzzle)
- **Bonus level** at end of chapter
- **Daily mini-challenge** (different from daily crossword)

This keeps the crossword at center stage while adding variety.
