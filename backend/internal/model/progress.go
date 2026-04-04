package model

import (
	"time"

	"github.com/google/uuid"
)

type UserLevelProgress struct {
	UserID      uuid.UUID  `gorm:"type:uuid;primaryKey" json:"user_id"`
	LevelID     uint       `gorm:"primaryKey" json:"level_id"`
	Stars       int        `gorm:"default:0" json:"stars"`
	BestScore   int        `gorm:"default:0" json:"best_score"`
	Attempts    int        `gorm:"default:0" json:"attempts"`
	CompletedAt *time.Time `json:"completed_at"`
}

type UserPuzzleLog struct {
	ID          uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID      uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	PuzzleID    uint      `gorm:"not null" json:"puzzle_id"`
	IsCorrect   bool      `json:"is_correct"`
	XPEarned    int       `json:"xp_earned"`
	TimeTakenMs int       `json:"time_taken_ms"`
	PlayedAt    time.Time `gorm:"default:now()" json:"played_at"`
}
