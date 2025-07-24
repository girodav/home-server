
# List your service directories here
SERVICES = caddy media-center monitoring paperless-ngx scrutiny uhf-server

.PHONY: up down restart help

help:
	@echo "Available commands:"
	@echo "  up       - Start all services"
	@echo "  down     - Stop all services"
	@echo "  restart  - Restart all services"
	@echo ""
	@echo "Services: $(SERVICES)"

up:
	@for service in $(SERVICES); do \
		if [ -d "./$$service" ]; then \
			echo "Starting $$service..."; \
			cd ./$$service && docker compose pull && docker compose up -d; \
			cd ..; \
		fi; \
	done

down:
	@for service in $(SERVICES); do \
		if [ -d "./$$service" ]; then \
			echo "Stopping $$service..."; \
			cd ./$$service && docker compose down; \
			cd ..; \
		fi; \
	done

restart: down
	@sleep 2
	@$(MAKE) up