package service

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/hayk/math-game-backend/internal/model"
	"gorm.io/gorm"
)

type GameService struct {
	db      *gorm.DB
	energy  *EnergyService
}

func NewGameService(db *gorm.DB, energy *EnergyService) *GameService {
	return &GameService{db: db, energy: energy}
}

// --- Responses ---

type TierResponse struct {
	ID       uint   `json:"id"`
	Name     string `json:"name"`
	MinGrade int    `json:"min_grade"`
	MaxGrade int    `json:"max_grade"`
	Unlocked bool   `json:"unlocked"`
}

type LevelResponse struct {
	ID        uint `json:"id"`
	Number    int  `json:"number"`
	Stars     int  `json:"stars"`
	Unlocked  bool `json:"unlocked"`
	Completed bool `json:"completed"`
}

type PuzzleResponse struct {
	ID           uint            `json:"id"`
	Data         json.RawMessage `json:"data"`
	TimeLimitSec int             `json:"time_limit_sec"`
}

type SubmitRequest struct {
	Cells       []AnswerCell `json:"cells"`
	TimeTakenMs int          `json:"time_taken_ms"`
	WrongMoves  int          `json:"wrong_moves"`
}

type AnswerCell struct {
	Row   int `json:"row"`
	Col   int `json:"col"`
	Value int `json:"value"`
}

type SubmitResponse struct {
	Correct   bool `json:"correct"`
	Stars     int  `json:"stars"`
	XPEarned  int  `json:"xp_earned"`
	TotalXP   int  `json:"total_xp"`
}

type ProgressResponse struct {
	TierID  uint `json:"tier_id"`
	LevelID uint `json:"level_id"`
	Stars   int  `json:"stars"`
}

// --- Methods ---

func (s *GameService) ListTiers(userID uuid.UUID, lang string) ([]TierResponse, error) {
	var tiers []model.Tier
	if err := s.db.Order("sort_order").Find(&tiers).Error; err != nil {
		return nil, err
	}

	// Get user's XP to determine unlocked tiers
	var stats model.UserStats
	s.db.First(&stats, "user_id = ?", userID)

	result := make([]TierResponse, len(tiers))
	for i, t := range tiers {
		result[i] = TierResponse{
			ID:       t.ID,
			Name:     t.Name(lang),
			MinGrade: t.MinGrade,
			MaxGrade: t.MaxGrade,
			Unlocked: i == 0 || stats.XP >= (i*500), // first tier always unlocked
		}
	}
	return result, nil
}

func (s *GameService) ListLevels(userID uuid.UUID, tierID uint) ([]LevelResponse, error) {
	var levels []model.Level
	if err := s.db.Where("tier_id = ?", tierID).Order("number").Find(&levels).Error; err != nil {
		return nil, err
	}

	// Get user progress for these levels
	var progress []model.UserLevelProgress
	levelIDs := make([]uint, len(levels))
	for i, l := range levels {
		levelIDs[i] = l.ID
	}
	s.db.Where("user_id = ? AND level_id IN ?", userID, levelIDs).Find(&progress)

	progressMap := map[uint]model.UserLevelProgress{}
	for _, p := range progress {
		progressMap[p.LevelID] = p
	}

	result := make([]LevelResponse, len(levels))
	for i, l := range levels {
		p := progressMap[l.ID]
		completed := p.CompletedAt != nil
		unlocked := i == 0 // first level always unlocked
		if i > 0 {
			prevP := progressMap[levels[i-1].ID]
			unlocked = prevP.CompletedAt != nil
		}

		result[i] = LevelResponse{
			ID:        l.ID,
			Number:    l.Number,
			Stars:     p.Stars,
			Unlocked:  unlocked,
			Completed: completed,
		}
	}
	return result, nil
}

func (s *GameService) GetPuzzle(userID uuid.UUID, levelID uint) (*PuzzleResponse, error) {
	// Get a random puzzle for this level
	var puzzle model.Puzzle
	err := s.db.Where("level_id = ?", levelID).
		Order("RANDOM()").
		First(&puzzle).Error
	if err != nil {
		return nil, errors.New("no puzzles available for this level")
	}

	return &PuzzleResponse{
		ID:           puzzle.ID,
		Data:         json.RawMessage(puzzle.Data),
		TimeLimitSec: puzzle.TimeLimitSec,
	}, nil
}

func (s *GameService) SubmitPuzzle(userID uuid.UUID, puzzleID uint, req SubmitRequest) (*SubmitResponse, error) {
	// Fetch puzzle with answer
	var puzzle model.Puzzle
	if err := s.db.First(&puzzle, puzzleID).Error; err != nil {
		return nil, errors.New("puzzle not found")
	}

	// Parse stored answer
	var storedAnswer struct {
		Cells []AnswerCell `json:"cells"`
	}
	if err := json.Unmarshal(puzzle.Answer, &storedAnswer); err != nil {
		return nil, errors.New("invalid puzzle answer data")
	}

	// Compare answers
	correct := compareAnswers(storedAnswer.Cells, req.Cells)

	// Calculate stars
	stars := 0
	xpEarned := 0
	if correct {
		stars = calculateStars(req.WrongMoves, req.TimeTakenMs, puzzle.TimeLimitSec)
		switch stars {
		case 3:
			xpEarned = 100
		case 2:
			xpEarned = 50
		default:
			xpEarned = 25
		}
	}

	// Update progress and stats in a transaction
	var totalXP int
	err := s.db.Transaction(func(tx *gorm.DB) error {
		// Upsert level progress
		var progress model.UserLevelProgress
		tx.FirstOrCreate(&progress, model.UserLevelProgress{
			UserID:  userID,
			LevelID: puzzle.LevelID,
		})

		progress.Attempts++
		if correct {
			now := time.Now()
			progress.CompletedAt = &now
			if stars > progress.Stars {
				progress.Stars = stars
			}
			if xpEarned > progress.BestScore {
				progress.BestScore = xpEarned
			}
		}
		if err := tx.Save(&progress).Error; err != nil {
			return err
		}

		// Update user stats
		if correct && xpEarned > 0 {
			if err := tx.Model(&model.UserStats{}).
				Where("user_id = ?", userID).
				Updates(map[string]interface{}{
					"xp": gorm.Expr("xp + ?", xpEarned),
				}).Error; err != nil {
				return err
			}
		}

		// Update streak
		if correct {
			updateStreak(tx, userID)
		}

		// Log
		log := model.UserPuzzleLog{
			UserID:      userID,
			PuzzleID:    puzzleID,
			IsCorrect:   correct,
			XPEarned:    xpEarned,
			TimeTakenMs: req.TimeTakenMs,
			PlayedAt:    time.Now(),
		}
		if err := tx.Create(&log).Error; err != nil {
			return err
		}

		// Get updated XP
		var stats model.UserStats
		tx.First(&stats, "user_id = ?", userID)
		totalXP = stats.XP
		return nil
	})
	if err != nil {
		return nil, err
	}

	return &SubmitResponse{
		Correct:  correct,
		Stars:    stars,
		XPEarned: xpEarned,
		TotalXP:  totalXP,
	}, nil
}

func (s *GameService) GetProgress(userID uuid.UUID) ([]ProgressResponse, error) {
	var progress []model.UserLevelProgress
	if err := s.db.Where("user_id = ?", userID).Find(&progress).Error; err != nil {
		return nil, err
	}

	// Get level -> tier mapping
	var levels []model.Level
	s.db.Find(&levels)
	tierMap := map[uint]uint{}
	for _, l := range levels {
		tierMap[l.ID] = l.TierID
	}

	result := make([]ProgressResponse, len(progress))
	for i, p := range progress {
		result[i] = ProgressResponse{
			TierID:  tierMap[p.LevelID],
			LevelID: p.LevelID,
			Stars:   p.Stars,
		}
	}
	return result, nil
}

func compareAnswers(expected, submitted []AnswerCell) bool {
	if len(expected) != len(submitted) {
		return false
	}
	expectedMap := map[string]int{}
	for _, c := range expected {
		key := cellKey(c.Row, c.Col)
		expectedMap[key] = c.Value
	}
	for _, c := range submitted {
		key := cellKey(c.Row, c.Col)
		if expectedMap[key] != c.Value {
			return false
		}
	}
	return true
}

func cellKey(row, col int) string {
	return string(rune('0'+row)) + "," + string(rune('0'+col))
}

func calculateStars(wrongMoves, timeTakenMs, timeLimitSec int) int {
	overTime := timeTakenMs > timeLimitSec*1000
	wayOverTime := timeTakenMs > timeLimitSec*1500

	if wrongMoves == 0 && !overTime {
		return 3
	}
	if wrongMoves <= 2 && !wayOverTime {
		return 2
	}
	return 1
}

func updateStreak(tx *gorm.DB, userID uuid.UUID) {
	var stats model.UserStats
	tx.First(&stats, "user_id = ?", userID)

	today := time.Now().Truncate(24 * time.Hour)

	if stats.StreakLastDate != nil {
		lastDate := stats.StreakLastDate.Truncate(24 * time.Hour)
		if lastDate.Equal(today) {
			return // already played today
		}
		yesterday := today.Add(-24 * time.Hour)
		if lastDate.Equal(yesterday) {
			tx.Model(&stats).Where("user_id = ?", userID).Updates(map[string]interface{}{
				"streak":           stats.Streak + 1,
				"streak_last_date": today,
			})
			return
		}
	}

	// Reset streak
	tx.Model(&stats).Where("user_id = ?", userID).Updates(map[string]interface{}{
		"streak":           1,
		"streak_last_date": today,
	})
}
