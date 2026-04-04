package service

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/hayk/math-game-backend/internal/model"
	"gorm.io/gorm"
)

const (
	MaxEnergy       = 10
	RegenIntervalMin = 30
	RefillGemCost   = 10
)

type EnergyService struct {
	db *gorm.DB
}

func NewEnergyService(db *gorm.DB) *EnergyService {
	return &EnergyService{db: db}
}

type EnergyResponse struct {
	Energy      int       `json:"energy"`
	MaxEnergy   int       `json:"max_energy"`
	NextRegenAt *time.Time `json:"next_regen_at,omitempty"`
}

func (s *EnergyService) GetEnergy(userID uuid.UUID) (*EnergyResponse, error) {
	var stats model.UserStats
	if err := s.db.First(&stats, "user_id = ?", userID).Error; err != nil {
		return nil, errors.New("stats not found")
	}

	current, nextRegen := calculateCurrentEnergy(stats.Energy, stats.EnergyUpdatedAt)

	// Persist recalculated energy if it changed
	if current != stats.Energy {
		s.db.Model(&stats).Where("user_id = ?", userID).Updates(map[string]interface{}{
			"energy":            current,
			"energy_updated_at": time.Now(),
		})
	}

	resp := &EnergyResponse{
		Energy:    current,
		MaxEnergy: MaxEnergy,
	}
	if current < MaxEnergy {
		resp.NextRegenAt = &nextRegen
	}
	return resp, nil
}

func (s *EnergyService) ConsumeEnergy(userID uuid.UUID) error {
	var stats model.UserStats
	if err := s.db.First(&stats, "user_id = ?", userID).Error; err != nil {
		return errors.New("stats not found")
	}

	current, _ := calculateCurrentEnergy(stats.Energy, stats.EnergyUpdatedAt)
	if current <= 0 {
		return errors.New("not enough energy")
	}

	return s.db.Model(&stats).Where("user_id = ?", userID).Updates(map[string]interface{}{
		"energy":            current - 1,
		"energy_updated_at": time.Now(),
	}).Error
}

func (s *EnergyService) RefillWithGems(userID uuid.UUID) error {
	var stats model.UserStats
	if err := s.db.First(&stats, "user_id = ?", userID).Error; err != nil {
		return errors.New("stats not found")
	}

	if stats.Gems < RefillGemCost {
		return errors.New("not enough gems")
	}

	return s.db.Model(&stats).Where("user_id = ?", userID).Updates(map[string]interface{}{
		"energy":            MaxEnergy,
		"energy_updated_at": time.Now(),
		"gems":              stats.Gems - RefillGemCost,
	}).Error
}

func calculateCurrentEnergy(storedEnergy int, updatedAt time.Time) (int, time.Time) {
	elapsed := time.Since(updatedAt)
	regenCount := int(elapsed.Minutes()) / RegenIntervalMin
	current := storedEnergy + regenCount
	if current > MaxEnergy {
		current = MaxEnergy
	}

	minutesSinceLast := int(elapsed.Minutes()) % RegenIntervalMin
	nextRegen := time.Now().Add(time.Duration(RegenIntervalMin-minutesSinceLast) * time.Minute)
	return current, nextRegen
}
