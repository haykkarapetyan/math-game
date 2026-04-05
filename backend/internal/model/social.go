package model

import (
	"time"

	"github.com/google/uuid"
)

type Friendship struct {
	ID        uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	FriendID  uuid.UUID `gorm:"type:uuid;not null" json:"friend_id"`
	Status    string    `gorm:"default:'pending'" json:"status"` // pending, accepted, rejected
	CreatedAt time.Time `json:"created_at"`
	Friend    User      `gorm:"foreignKey:FriendID" json:"friend,omitempty"`
	User      User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
}

type Referral struct {
	ID         uuid.UUID  `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	ReferrerID uuid.UUID  `gorm:"type:uuid;not null" json:"referrer_id"`
	ReferredID uuid.UUID  `gorm:"type:uuid;not null" json:"referred_id"`
	RewardedAt *time.Time `json:"rewarded_at"`
}

type Challenge struct {
	ID           uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	ChallengerID uuid.UUID `gorm:"type:uuid;not null" json:"challenger_id"`
	OpponentID   uuid.UUID `gorm:"type:uuid;not null" json:"opponent_id"`
	LevelID      uint      `gorm:"not null" json:"level_id"`
	PuzzleID     *uint     `json:"puzzle_id"`
	Status       string    `gorm:"default:'pending'" json:"status"` // pending, accepted, completed
	CreatedAt    time.Time `json:"created_at"`
	Challenger   User      `gorm:"foreignKey:ChallengerID" json:"challenger,omitempty"`
	Opponent     User      `gorm:"foreignKey:OpponentID" json:"opponent,omitempty"`
}

type ChallengeScore struct {
	ID          uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	ChallengeID uuid.UUID `gorm:"type:uuid;not null" json:"challenge_id"`
	UserID      uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	Score       int       `json:"score"`
	Stars       int       `json:"stars"`
	CompletedAt time.Time `json:"completed_at"`
}

type LeaderboardWeekly struct {
	ID         uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	UserID     uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	XPThisWeek int       `json:"xp_this_week"`
	WeekStart  time.Time `gorm:"type:date" json:"week_start"`
	User       User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
}
