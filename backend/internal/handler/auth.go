package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/hayk/math-game-backend/internal/middleware"
	"github.com/hayk/math-game-backend/internal/service"
)

func RegisterAuthRoutes(router fiber.Router, svc *service.AuthService, secret string) {
	auth := router.Group("/auth")
	auth.Post("/register", registerHandler(svc))
	auth.Post("/login", loginHandler(svc))
	auth.Post("/refresh", refreshHandler(svc))
	auth.Get("/me", middleware.JWTAuth(secret), meHandler(svc))
}

func registerHandler(svc *service.AuthService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		var req service.RegisterRequest
		if err := c.BodyParser(&req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
		}
		resp, err := svc.Register(req)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"error": err.Error()})
		}
		return c.Status(201).JSON(resp)
	}
}

func loginHandler(svc *service.AuthService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		var req service.LoginRequest
		if err := c.BodyParser(&req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
		}
		resp, err := svc.Login(req)
		if err != nil {
			return c.Status(401).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func refreshHandler(svc *service.AuthService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		var req service.RefreshRequest
		if err := c.BodyParser(&req); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
		}
		resp, err := svc.Refresh(req)
		if err != nil {
			return c.Status(401).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}

func meHandler(svc *service.AuthService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := middleware.GetUserID(c)
		resp, err := svc.GetMe(userID)
		if err != nil {
			return c.Status(404).JSON(fiber.Map{"error": err.Error()})
		}
		return c.JSON(resp)
	}
}
