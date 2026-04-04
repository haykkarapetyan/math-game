package model

import "gorm.io/datatypes"

type Puzzle struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	LevelID      uint           `json:"level_id"`
	Type         string         `gorm:"default:'crossword'" json:"type"`
	Difficulty   int            `gorm:"default:1" json:"difficulty"`
	Data         datatypes.JSON `gorm:"type:jsonb;not null" json:"data"`
	Answer       datatypes.JSON `gorm:"type:jsonb;not null" json:"-"`
	TimeLimitSec int            `gorm:"default:120" json:"time_limit_sec"`
}
