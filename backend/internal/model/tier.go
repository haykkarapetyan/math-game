package model

type Tier struct {
	ID        uint    `gorm:"primaryKey" json:"id"`
	NameHy    string  `json:"name_hy"`
	NameEn    string  `json:"name_en"`
	NameRu    string  `json:"name_ru"`
	MinGrade  int     `json:"min_grade"`
	MaxGrade  int     `json:"max_grade"`
	SortOrder int     `json:"sort_order"`
	Levels    []Level `gorm:"foreignKey:TierID" json:"levels,omitempty"`
}

func (t *Tier) Name(lang string) string {
	switch lang {
	case "en":
		return t.NameEn
	case "ru":
		return t.NameRu
	default:
		return t.NameHy
	}
}
