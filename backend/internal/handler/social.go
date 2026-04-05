package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/hayk/math-game-backend/internal/middleware"
	"github.com/hayk/math-game-backend/internal/service"
)

func RegisterSocialRoutes(router fiber.Router, svc *service.SocialService, authMw fiber.Handler) {
	router.Get("/friends", authMw, getFriends(svc))
	router.Post("/friends/add", authMw, addFriend(svc))
	router.Get("/leaderboard", authMw, getLeaderboard(svc))
	router.Post("/challenges", authMw, createChallenge(svc))
	router.Get("/challenges", authMw, getChallenges(svc))
}

func getFriends(svc *service.SocialService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		resp, err := svc.GetFriends(userID)
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func addFriend(svc *service.SocialService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		var req service.AddFriendRequest
		if err := c.BodyParser(&req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
		}
		if err := svc.AddFriend(userID, req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(fiber.Map{"status": "ok"})
	}
}

func getLeaderboard(svc *service.SocialService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		scope := c.Query("scope", "global")
		resp, err := svc.GetLeaderboard(userID, scope)
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func createChallenge(svc *service.SocialService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		var req service.CreateChallengeRequest
		if err := c.BodyParser(&req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
		}
		resp, err := svc.CreateChallenge(userID, req)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"error": err.Error()})
		}
		return c.Status(201).JSON(resp)
	}
}

func getChallenges(svc *service.SocialService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		resp, err := svc.GetChallenges(userID)
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}
