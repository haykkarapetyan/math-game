package service

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/hayk/math-game-backend/internal/model"
	"gorm.io/gorm"
)

type SocialService struct {
	db *gorm.DB
}

func NewSocialService(db *gorm.DB) *SocialService {
	return &SocialService{db: db}
}

// --- Friends ---

type FriendResponse struct {
	ID       uuid.UUID `json:"id"`
	Username string    `json:"username"`
	Avatar   string    `json:"avatar"`
	XP       int       `json:"xp"`
	IsOnline bool      `json:"is_online"`
	Status   string    `json:"status"`
}

func (s *SocialService) GetFriends(userID uuid.UUID) ([]FriendResponse, error) {
	var friendships []model.Friendship
	s.db.Preload("Friend").
		Where("user_id = ? AND status = 'accepted'", userID).
		Find(&friendships)

	// Also get reverse friendships (where user is the friend_id)
	var reverseFriendships []model.Friendship
	s.db.Preload("User").
		Where("friend_id = ? AND status = 'accepted'", userID).
		Find(&reverseFriendships)

	result := make([]FriendResponse, 0)
	seen := map[uuid.UUID]bool{}

	for _, f := range friendships {
		if seen[f.FriendID] {
			continue
		}
		seen[f.FriendID] = true
		var stats model.UserStats
		s.db.First(&stats, "user_id = ?", f.FriendID)
		result = append(result, FriendResponse{
			ID:       f.FriendID,
			Username: f.Friend.Username,
			Avatar:   f.Friend.Avatar,
			XP:       stats.XP,
			Status:   f.Status,
		})
	}

	for _, f := range reverseFriendships {
		if seen[f.UserID] {
			continue
		}
		seen[f.UserID] = true
		var stats model.UserStats
		s.db.First(&stats, "user_id = ?", f.UserID)
		result = append(result, FriendResponse{
			ID:       f.UserID,
			Username: f.User.Username,
			Avatar:   f.User.Avatar,
			XP:       stats.XP,
			Status:   f.Status,
		})
	}

	return result, nil
}

type AddFriendRequest struct {
	FriendUsername string `json:"friend_username"`
}

func (s *SocialService) AddFriend(userID uuid.UUID, req AddFriendRequest) error {
	if req.FriendUsername == "" {
		return errors.New("friend_username is required")
	}

	var friend model.User
	if err := s.db.Where("username = ?", req.FriendUsername).First(&friend).Error; err != nil {
		return errors.New("user not found")
	}

	if friend.ID == userID {
		return errors.New("cannot add yourself")
	}

	// Check if already friends
	var existing model.Friendship
	err := s.db.Where(
		"(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)",
		userID, friend.ID, friend.ID, userID,
	).First(&existing).Error
	if err == nil {
		return errors.New("already friends or request pending")
	}

	// Create friendship (auto-accept for now)
	friendship := model.Friendship{
		ID:       uuid.New(),
		UserID:   userID,
		FriendID: friend.ID,
		Status:   "accepted",
	}
	return s.db.Create(&friendship).Error
}

// --- Leaderboard ---

type LeaderboardResponse struct {
	Rank     int       `json:"rank"`
	UserID   uuid.UUID `json:"user_id"`
	Username string    `json:"username"`
	Avatar   string    `json:"avatar"`
	XP       int       `json:"xp"`
	IsSelf   bool      `json:"is_self"`
}

func (s *SocialService) GetLeaderboard(userID uuid.UUID, scope string) ([]LeaderboardResponse, error) {
	if scope == "friends" {
		return s.getFriendsLeaderboard(userID)
	}
	return s.getGlobalLeaderboard(userID)
}

func (s *SocialService) getGlobalLeaderboard(userID uuid.UUID) ([]LeaderboardResponse, error) {
	var stats []model.UserStats
	s.db.Order("xp DESC").Limit(50).Find(&stats)

	result := make([]LeaderboardResponse, 0, len(stats))
	for i, st := range stats {
		var user model.User
		s.db.First(&user, "id = ?", st.UserID)
		result = append(result, LeaderboardResponse{
			Rank:     i + 1,
			UserID:   st.UserID,
			Username: user.Username,
			Avatar:   user.Avatar,
			XP:       st.XP,
			IsSelf:   st.UserID == userID,
		})
	}
	return result, nil
}

func (s *SocialService) getFriendsLeaderboard(userID uuid.UUID) ([]LeaderboardResponse, error) {
	// Get friend IDs
	friends, _ := s.GetFriends(userID)
	friendIDs := []uuid.UUID{userID}
	for _, f := range friends {
		friendIDs = append(friendIDs, f.ID)
	}

	var stats []model.UserStats
	s.db.Where("user_id IN ?", friendIDs).Order("xp DESC").Find(&stats)

	result := make([]LeaderboardResponse, 0, len(stats))
	for i, st := range stats {
		var user model.User
		s.db.First(&user, "id = ?", st.UserID)
		result = append(result, LeaderboardResponse{
			Rank:     i + 1,
			UserID:   st.UserID,
			Username: user.Username,
			Avatar:   user.Avatar,
			XP:       st.XP,
			IsSelf:   st.UserID == userID,
		})
	}
	return result, nil
}

// --- Challenges ---

type CreateChallengeRequest struct {
	OpponentID string `json:"opponent_id"`
	LevelID    uint   `json:"level_id"`
}

type ChallengeResponse struct {
	ID             uuid.UUID `json:"id"`
	ChallengerName string    `json:"challenger_name"`
	OpponentName   string    `json:"opponent_name"`
	LevelID        uint      `json:"level_id"`
	Status         string    `json:"status"`
	CreatedAt      time.Time `json:"created_at"`
}

func (s *SocialService) CreateChallenge(userID uuid.UUID, req CreateChallengeRequest) (*ChallengeResponse, error) {
	opponentID, err := uuid.Parse(req.OpponentID)
	if err != nil {
		return nil, errors.New("invalid opponent_id")
	}

	// Pick a random puzzle for the level
	var puzzle model.Puzzle
	if err := s.db.Where("level_id = ?", req.LevelID).Order("RANDOM()").First(&puzzle).Error; err != nil {
		return nil, errors.New("no puzzle available for this level")
	}

	challenge := model.Challenge{
		ID:           uuid.New(),
		ChallengerID: userID,
		OpponentID:   opponentID,
		LevelID:      req.LevelID,
		PuzzleID:     &puzzle.ID,
		Status:       "pending",
	}
	if err := s.db.Create(&challenge).Error; err != nil {
		return nil, err
	}

	var challenger, opponent model.User
	s.db.First(&challenger, "id = ?", userID)
	s.db.First(&opponent, "id = ?", opponentID)

	return &ChallengeResponse{
		ID:             challenge.ID,
		ChallengerName: challenger.Username,
		OpponentName:   opponent.Username,
		LevelID:        req.LevelID,
		Status:         "pending",
		CreatedAt:      challenge.CreatedAt,
	}, nil
}

func (s *SocialService) GetChallenges(userID uuid.UUID) ([]ChallengeResponse, error) {
	var challenges []model.Challenge
	s.db.Preload("Challenger").Preload("Opponent").
		Where("challenger_id = ? OR opponent_id = ?", userID, userID).
		Order("created_at DESC").
		Limit(20).
		Find(&challenges)

	result := make([]ChallengeResponse, 0, len(challenges))
	for _, c := range challenges {
		result = append(result, ChallengeResponse{
			ID:             c.ID,
			ChallengerName: c.Challenger.Username,
			OpponentName:   c.Opponent.Username,
			LevelID:        c.LevelID,
			Status:         c.Status,
			CreatedAt:      c.CreatedAt,
		})
	}
	return result, nil
}
