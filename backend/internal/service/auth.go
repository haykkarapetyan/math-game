package service

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/hayk/math-game-backend/internal/config"
	"github.com/hayk/math-game-backend/internal/middleware"
	"github.com/hayk/math-game-backend/internal/model"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthService struct {
	db  *gorm.DB
	cfg *config.Config
}

func NewAuthService(db *gorm.DB, cfg *config.Config) *AuthService {
	return &AuthService{db: db, cfg: cfg}
}

type RegisterRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
	Country  string `json:"country"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type AuthResponse struct {
	AccessToken  string       `json:"access_token"`
	RefreshToken string       `json:"refresh_token"`
	User         UserResponse `json:"user"`
}

type UserResponse struct {
	ID       uuid.UUID `json:"id"`
	Username string    `json:"username"`
	Email    string    `json:"email"`
	Language string    `json:"language"`
	Avatar   string    `json:"avatar"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

func (s *AuthService) Register(req RegisterRequest) (*AuthResponse, error) {
	if req.Username == "" || req.Email == "" || req.Password == "" {
		return nil, errors.New("username, email, and password are required")
	}
	if len(req.Password) < 6 {
		return nil, errors.New("password must be at least 6 characters")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	country := req.Country
	if len(country) > 2 {
		country = country[:2]
	}

	user := model.User{
		ID:           uuid.New(),
		Username:     req.Username,
		Email:        req.Email,
		PasswordHash: string(hash),
		Language:     "hy",
		Avatar:       "fox",
		Country:      country,
		CreatedAt:    time.Now(),
	}

	stats := model.UserStats{
		UserID:          user.ID,
		XP:              0,
		Coins:           100,
		Gems:            0,
		Energy:          10,
		EnergyUpdatedAt: time.Now(),
		Streak:          0,
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&user).Error; err != nil {
			return err
		}
		return tx.Create(&stats).Error
	})
	if err != nil {
		return nil, errors.New("username or email already taken")
	}

	return s.generateAuthResponse(user)
}

func (s *AuthService) Login(req LoginRequest) (*AuthResponse, error) {
	var user model.User
	if err := s.db.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return nil, errors.New("invalid email or password")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid email or password")
	}

	return s.generateAuthResponse(user)
}

func (s *AuthService) Refresh(req RefreshRequest) (*AuthResponse, error) {
	claims, err := middleware.ValidateToken(req.RefreshToken, s.cfg.JWTSecret)
	if err != nil {
		return nil, errors.New("invalid refresh token")
	}
	if claims.Subject != "refresh" {
		return nil, errors.New("not a refresh token")
	}

	var user model.User
	if err := s.db.First(&user, "id = ?", claims.UserID).Error; err != nil {
		return nil, errors.New("user not found")
	}

	return s.generateAuthResponse(user)
}

func (s *AuthService) GetMe(userID uuid.UUID) (*MeResponse, error) {
	var user model.User
	if err := s.db.First(&user, "id = ?", userID).Error; err != nil {
		return nil, errors.New("user not found")
	}

	var stats model.UserStats
	if err := s.db.First(&stats, "user_id = ?", userID).Error; err != nil {
		return nil, errors.New("stats not found")
	}

	return &MeResponse{
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

type MeResponse struct {
	User  UserResponse  `json:"user"`
	Stats StatsResponse `json:"stats"`
}

type StatsResponse struct {
	XP     int `json:"xp"`
	Coins  int `json:"coins"`
	Gems   int `json:"gems"`
	Energy int `json:"energy"`
	Streak int `json:"streak"`
}

func (s *AuthService) generateAuthResponse(user model.User) (*AuthResponse, error) {
	accessToken, err := middleware.GenerateAccessToken(user.ID, s.cfg.JWTSecret, s.cfg.JWTExpiryHours)
	if err != nil {
		return nil, err
	}

	refreshToken, err := middleware.GenerateRefreshToken(user.ID, s.cfg.JWTSecret, s.cfg.JWTRefreshExpiryHours)
	if err != nil {
		return nil, err
	}

	return &AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User: UserResponse{
			ID:       user.ID,
			Username: user.Username,
			Email:    user.Email,
			Language: user.Language,
			Avatar:   user.Avatar,
		},
	}, nil
}
