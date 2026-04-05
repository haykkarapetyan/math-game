package main

import (
	"fmt"
	"log"

	"github.com/hayk/math-game-backend/internal/config"
	"github.com/hayk/math-game-backend/internal/model"
	"github.com/hayk/math-game-backend/pkg/puzzle"
	"gorm.io/datatypes"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	cfg := config.Load()
	db, err := gorm.Open(postgres.Open(cfg.DSN()), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Enable UUID extension
	db.Exec(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`)

	// Auto-migrate tables
	if err := db.AutoMigrate(
		&model.User{},
		&model.UserStats{},
		&model.Tier{},
		&model.Level{},
		&model.Puzzle{},
		&model.UserLevelProgress{},
		&model.UserPuzzleLog{},
		&model.Friendship{},
		&model.Referral{},
		&model.Challenge{},
		&model.ChallengeScore{},
		&model.LeaderboardWeekly{},
	); err != nil {
		log.Fatal("Failed to migrate:", err)
	}
	fmt.Println("Tables migrated successfully")

	// Seed tiers
	tiers := []model.Tier{
		{ID: 1, NameHy: "Դdelays 1-5", NameEn: "Grades 1-5", NameRu: "Классы 1-5", MinGrade: 1, MaxGrade: 5, SortOrder: 1},
		{ID: 2, NameHy: "Դdelays 5-7", NameEn: "Grades 5-7", NameRu: "Классы 5-7", MinGrade: 5, MaxGrade: 7, SortOrder: 2},
		{ID: 3, NameHy: "Դdelays 7-10", NameEn: "Grades 7-10", NameRu: "Классы 7-10", MinGrade: 7, MaxGrade: 10, SortOrder: 3},
		{ID: 4, NameHy: "Համalsar", NameEn: "University", NameRu: "Университет", MinGrade: 11, MaxGrade: 16, SortOrder: 4},
	}
	for _, t := range tiers {
		db.FirstOrCreate(&t, model.Tier{ID: t.ID})
	}
	fmt.Println("Tiers seeded: 4")

	// Seed levels (10 per tier, tiers 1-2 for now)
	levelID := uint(1)
	for _, tierID := range []uint{1, 2} {
		for num := 1; num <= 10; num++ {
			level := model.Level{
				ID:     levelID,
				TierID: tierID,
				Number: num,
				TitleEn: fmt.Sprintf("Level %d", num),
				TitleHy: fmt.Sprintf("Մակdelays %d", num),
				TitleRu: fmt.Sprintf("Уровень %d", num),
			}
			db.FirstOrCreate(&level, model.Level{ID: level.ID})
			levelID++
		}
	}
	fmt.Println("Levels seeded: 20")

	// Seed puzzles (5 per level)
	puzzleCount := 0
	var levels []model.Level
	db.Find(&levels)
	for _, level := range levels {
		// Check if puzzles already exist for this level
		var count int64
		db.Model(&model.Puzzle{}).Where("level_id = ?", level.ID).Count(&count)
		if count >= 5 {
			continue
		}

		cfg := puzzle.GetLevelConfig(level.Number)
		for i := 0; i < 5; i++ {
			p := puzzle.Generate(cfg)
			if p == nil {
				continue
			}
			dbPuzzle := model.Puzzle{
				LevelID:      level.ID,
				Type:         "crossword",
				Difficulty:   level.Number,
				Data:         datatypes.JSON(p.Data),
				Answer:       datatypes.JSON(p.Answer),
				TimeLimitSec: p.TimeLimitSec,
			}
			db.Create(&dbPuzzle)
			puzzleCount++
		}
	}
	fmt.Printf("Puzzles seeded: %d\n", puzzleCount)
	fmt.Println("Seeding complete!")
}
