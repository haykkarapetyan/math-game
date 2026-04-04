package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/hayk/math-game-backend/internal/middleware"
	"github.com/hayk/math-game-backend/internal/service"
)

func RegisterEnergyRoutes(router fiber.Router, svc *service.EnergyService, authMw fiber.Handler) {
	router.Get("/energy", authMw, getEnergy(svc))
	router.Post("/energy/refill", authMw, refillEnergy(svc))
}

func getEnergy(svc *service.EnergyService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		resp, err := svc.GetEnergy(userID)
		if err != nil {
			return c.Status(404).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func refillEnergy(svc *service.EnergyService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		if err := svc.RefillWithGems(userID); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(fiber.Map{"status": "ok", "energy": service.MaxEnergy})
	}
}
