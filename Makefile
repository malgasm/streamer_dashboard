UI_IMAGE_NAME ?= streamer_dashboard_ui
BACKEND_IMAGE_NAME ?= streamer_dashboard_backend

.PHONY: build run

run:
	docker-compose --env-file .env up

build:
	docker-compose build

default: run
