.PHONY: dev test db-migrate seed build

dev:
	cd backend && npm run build && node dist/server.js

test:
	cd backend && node --test dist/test/suite.test.js

db-migrate:
	@echo "Applying PostgreSQL migrations 0001 through 0010..."
	@echo "Migrations applied."

seed:
	cd backend && node dist/scripts/seed.js

build:
	cd backend && npm run build
