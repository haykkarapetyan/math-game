package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/hayk/math-game-backend/internal/middleware"
	"github.com/hayk/math-game-backend/internal/service"
)

func RegisterProfileRoutes(router fiber.Router, svc *service.UserService, authMw fiber.Handler) {
	router.Get("/profile", authMw, getProfile(svc))
	router.Patch("/profile", authMw, updateProfile(svc))
}

func getProfile(svc *service.UserService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		resp, err := svc.GetProfile(userID)
		if err != nil {
			return c.Status(404).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func updateProfile(svc *service.UserService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		var req service.UpdateProfileRequest
		if err := c.BodyParser(&req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
		}
		if err := svc.UpdateProfile(userID, req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(fiber.Map{"status": "ok"})
	}
}
