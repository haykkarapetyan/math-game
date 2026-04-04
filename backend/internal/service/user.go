package service

import (
	"errors"

	"github.com/google/uuid"
	"github.com/hayk/math-game-backend/internal/model"
	"gorm.io/gorm"
)

type UserService struct {
	db *gorm.DB
}

func NewUserService(db *gorm.DB) *UserService {
	return &UserService{db: db}
}

type ProfileResponse struct {
	User  UserResponse  `json:"user"`
	Stats StatsResponse `json:"stats"`
}

type UpdateProfileRequest struct {
	Username *string `json:"username,omitempty"`
	Language *string `json:"language,omitempty"`
	Avatar   *string `json:"avatar,omitempty"`
}

func (s *UserService) GetProfile(userID uuid.UUID) (*ProfileResponse, error) {
	var user model.User
	if err := s.db.First(&user, "id = ?", userID).Error; err != nil {
		return nil, errors.New("user not found")
	}

	var stats model.UserStats
	if err := s.db.First(&stats, "user_id = ?", userID).Error; err != nil {
		return nil, errors.New("stats not found")
	}

	return &ProfileResponse{
		User: UserResponse{
			ID:       user.ID,
			Username: user.Username,
			Email:    user.Email,
			Language: user.Language,
			Avatar:   user.Avatar,
		},
		Stats: StatsResponse{
			XP:     stats.XP,
			Coins:  stats.Coins,
			Gems:   stats.Gems,
			Energy: stats.Energy,
			Streak: stats.Streak,
		},
	}, nil
}

func (s *UserService) UpdateProfile(userID uuid.UUID, req UpdateProfileRequest) error {
	updates := map[string]interface{}{}

	if req.Username != nil && *req.Username != "" {
		updates["username"] = *req.Username
	}
	if req.Language != nil {
		lang := *req.Language
		if lang != "hy" && lang != "en" && lang != "ru" {
			return errors.New("language must be hy, en, or ru")
		}
		updates["language"] = lang
	}
	if req.Avatar != nil {
		if !model.IsValidAvatar(*req.Avatar) {
			return errors.New("invalid avatar")
		}
		updates["avatar"] = *req.Avatar
	}

	if len(updates) == 0 {
		return nil
	}

	return s.db.Model(&model.User{}).Where("id = ?", userID).Updates(updates).Error
}
