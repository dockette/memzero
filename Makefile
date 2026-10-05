# Include variables
include .env.dist
-include .env
export

.PHONY: build
build:
	docker buildx build --platform ${DOCKER_PLATFORM} --build-arg MEM0_VERSION=${MEM0_VERSION} -t ${DOCKER_SERVER_IMAGE} -t ${DOCKER_SERVER_IMAGE}-${MEM0_VERSION} .
	docker buildx build --platform ${DOCKER_PLATFORM} --build-arg MEM0_VERSION=${MEM0_VERSION} -t ${DOCKER_DASHBOARD_IMAGE} -t ${DOCKER_DASHBOARD_IMAGE}-${MEM0_VERSION} dashboard

.PHONY: push
push:
	docker push ${DOCKER_SERVER_IMAGE}
	docker push ${DOCKER_SERVER_IMAGE}-${MEM0_VERSION}
	docker push ${DOCKER_DASHBOARD_IMAGE}
	docker push ${DOCKER_DASHBOARD_IMAGE}-${MEM0_VERSION}

.PHONY: up
up:
	docker compose up

.PHONY: down
down:
	docker compose down

.PHONY: clean
clean:
	docker compose down
	rm -rf .docker

.PHONY: logs
logs:
	docker compose logs -f

.PHONY: enter
enter:
	docker compose exec mem0 bash

.PHONY: health
health:
	@echo "API:       $$(curl -s -o /dev/null -w '%{http_code}' http://localhost:${MEM0_PORT}/docs)"
	@echo "Dashboard: $$(curl -s -o /dev/null -w '%{http_code}' http://localhost:${DASHBOARD_PORT}/api/health)"
	@echo "Postgres:  $$(docker compose exec -T postgres pg_isready -q && echo 'ok' || echo 'down')"

.PHONY: test
test: _testcase-server _testcase-dashboard

.PHONY: _testcase-server
_testcase-server:
	docker run --rm --platform ${DOCKER_PLATFORM} ${DOCKER_SERVER_IMAGE} python -c "import fastapi, uvicorn, alembic, mem0; print('mem0', mem0.__version__)"
	docker run --rm --platform ${DOCKER_PLATFORM} ${DOCKER_SERVER_IMAGE} test -f /app/main.py
	docker run --rm --platform ${DOCKER_PLATFORM} ${DOCKER_SERVER_IMAGE} alembic --version

.PHONY: _testcase-dashboard
_testcase-dashboard:
	docker run --rm --platform ${DOCKER_PLATFORM} --entrypoint node ${DOCKER_DASHBOARD_IMAGE} --version
	docker run --rm --platform ${DOCKER_PLATFORM} --entrypoint test ${DOCKER_DASHBOARD_IMAGE} -f /app/server.js
