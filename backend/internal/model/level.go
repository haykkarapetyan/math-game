package model

type Level struct {
	ID               uint     `gorm:"primaryKey" json:"id"`
	TierID           uint     `json:"tier_id"`
	Number           int      `json:"number"`
	TitleHy          string   `json:"title_hy"`
	TitleEn          string   `json:"title_en"`
	TitleRu          string   `json:"title_ru"`
	UnlockXPRequired int      `json:"unlock_xp_required"`
	Puzzles          []Puzzle `gorm:"foreignKey:LevelID" json:"puzzles,omitempty"`
}
