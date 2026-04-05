package main

import (
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	fiberlogger "github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/hayk/math-game-backend/internal/config"
	"github.com/hayk/math-game-backend/internal/handler"
	"github.com/hayk/math-game-backend/internal/middleware"
	"github.com/hayk/math-game-backend/internal/service"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	cfg := config.Load()

	// Connect to PostgreSQL
	db, err := gorm.Open(postgres.Open(cfg.DSN()), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	fmt.Println("Connected to PostgreSQL")

	// Fiber app
	app := fiber.New(fiber.Config{
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}
			return c.Status(code).JSON(fiber.Map{"error": err.Error()})
		},
	})

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,PATCH,DELETE,OPTIONS",
		AllowHeaders: "Origin,Content-Type,Authorization",
	}))
	app.Use(fiberlogger.New())

	// Services
	authMw := middleware.JWTAuth(cfg.JWTSecret)
	authSvc := service.NewAuthService(db, cfg)
	userSvc := service.NewUserService(db)
	energySvc := service.NewEnergyService(db)
	gameSvc := service.NewGameService(db, energySvc)
	socialSvc := service.NewSocialService(db)

	// Routes
	api := app.Group("/api")
	handler.RegisterAuthRoutes(api, authSvc, cfg.JWTSecret)
	handler.RegisterProfileRoutes(api, userSvc, authMw)
	handler.RegisterGameRoutes(api, gameSvc, authMw)
	handler.RegisterEnergyRoutes(api, energySvc, authMw)
	handler.RegisterSocialRoutes(api, socialSvc, authMw)

	// Health check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})

	fmt.Printf("Server starting on :%s\n", cfg.ServerPort)
	log.Fatal(app.Listen(":" + cfg.ServerPort))
}
