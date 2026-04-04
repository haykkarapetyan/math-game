package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string

	RedisAddr string

	JWTSecret            string
	JWTExpiryHours       int
	JWTRefreshExpiryHours int

	ServerPort string
}

func (c *Config) DSN() string {
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.DBHost, c.DBPort, c.DBUser, c.DBPassword, c.DBName, c.DBSSLMode)
}

func Load() *Config {
	_ = godotenv.Load()

	return &Config{
		DBHost:                getEnv("DB_HOST", "localhost"),
		DBPort:                getEnv("DB_PORT", "5432"),
		DBUser:                getEnv("DB_USER", "mathgame"),
		DBPassword:            getEnv("DB_PASSWORD", "mathgame"),
		DBName:                getEnv("DB_NAME", "mathgame"),
		DBSSLMode:             getEnv("DB_SSLMODE", "disable"),
		RedisAddr:             getEnv("REDIS_ADDR", "localhost:6379"),
		JWTSecret:             getEnv("JWT_SECRET", "change-me"),
		JWTExpiryHours:        getEnvInt("JWT_EXPIRY_HOURS", 72),
		JWTRefreshExpiryHours: getEnvInt("JWT_REFRESH_EXPIRY_HOURS", 720),
		ServerPort:            getEnv("SERVER_PORT", "3000"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}
