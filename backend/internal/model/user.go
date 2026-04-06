package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID           uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	Username     string    `gorm:"uniqueIndex;not null" json:"username"`
	Email        string    `gorm:"uniqueIndex;not null" json:"email"`
	PasswordHash string    `gorm:"not null" json:"-"`
	Language     string    `gorm:"type:char(2);default:'hy'" json:"language"`
	Avatar       string    `gorm:"default:'fox'" json:"avatar"`
	Country      string    `gorm:"type:char(2);default:''" json:"country"`
	CreatedAt    time.Time `json:"created_at"`
}

type UserStats struct {
	UserID          uuid.UUID  `gorm:"type:uuid;primaryKey" json:"user_id"`
	XP              int        `gorm:"default:0" json:"xp"`
	Coins           int        `gorm:"default:100" json:"coins"`
	Gems            int        `gorm:"default:0" json:"gems"`
	Energy          int        `gorm:"default:10" json:"energy"`
	EnergyUpdatedAt time.Time  `gorm:"default:now()" json:"energy_updated_at"`
	Streak          int        `gorm:"default:0" json:"streak"`
	StreakLastDate   *time.Time `gorm:"type:date" json:"streak_last_date"`
}

var AllowedAvatars = []string{
	"fox", "cat", "dog", "bear", "panda", "lion",
	"unicorn", "owl", "eagle", "robot", "alien", "rocket",
}

func IsValidAvatar(avatar string) bool {
	for _, a := range AllowedAvatars {
		if a == avatar {
			return true
		}
	}
	return false
}
