package handler

import (
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/hayk/math-game-backend/internal/middleware"
	"github.com/hayk/math-game-backend/internal/service"
)

func RegisterGameRoutes(router fiber.Router, svc *service.GameService, authMw fiber.Handler) {
	router.Get("/tiers", authMw, listTiers(svc))
	router.Get("/tiers/:id/levels", authMw, listLevels(svc))
	router.Get("/levels/:id/puzzles", authMw, getPuzzle(svc))
	router.Post("/puzzles/:id/submit", authMw, submitPuzzle(svc))
	router.Get("/progress", authMw, getProgress(svc))
}

func listTiers(svc *service.GameService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		lang := c.Query("lang", "en")
		resp, err := svc.ListTiers(userID, lang)
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func listLevels(svc *service.GameService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		tierID, err := strconv.ParseUint(c.Params("id"), 10, 32)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid tier id"})
		}
		resp, err := svc.ListLevels(userID, uint(tierID))
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func getPuzzle(svc *service.GameService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		levelID, err := strconv.ParseUint(c.Params("id"), 10, 32)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid level id"})
		}
		resp, err := svc.GetPuzzle(userID, uint(levelID))
		if err != nil {
			return c.Status(404).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func submitPuzzle(svc *service.GameService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		puzzleID, err := strconv.ParseUint(c.Params("id"), 10, 32)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid puzzle id"})
		}
		var req service.SubmitRequest
		if err := c.BodyParser(&req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
		}
		resp, err := svc.SubmitPuzzle(userID, uint(puzzleID), req)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func getProgress(svc *service.GameService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		resp, err := svc.GetProgress(userID)
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}
