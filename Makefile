# Specify the docker-compose command
DOCKER_COMPOSE_CMD = $(shell which docker-compose 2>/dev/null || echo "docker compose")

# Set the docker-compose command
DOCKER_COMPOSE = $(DOCKER_COMPOSE_CMD)

# Specify the up command
UP = up -d

# Specify the down command
DOWN = down

# Specify the build command
BUILD = build

# Specify the restart command
RESTART = restart

# Specify the logs command
LOGS = logs -f

# Define the target to create the database
create-db:
	$(DOCKER_COMPOSE) exec postgres psql -U postgres -c "CREATE DATABASE postgres;"

# Define the target to run schema
create-schema:
	$(DOCKER_COMPOSE) exec postgres psql -U postgres -d postgres -f ./schema.sql

# Define the target to run seeds
seeds:
	$(DOCKER_COMPOSE) exec postgres psql -U postgres -d postgres -f ./seeds.sql

# Define the target up
up:
	$(DOCKER_COMPOSE) $(UP)

# Define the target down
down:
	$(DOCKER_COMPOSE) $(DOWN)

# Define the target build
build:
	$(DOCKER_COMPOSE) $(BUILD)

# Define the target restart
restart:
	$(DOCKER_COMPOSE) $(RESTART)

# Define the target logs
logs:
	$(DOCKER_COMPOSE) $(LOGS)

# Define the target ps
ps:
	$(DOCKER_COMPOSE) ps

# Define the target exec
exec:
	$(DOCKER_COMPOSE) exec

# Define the target stop
stop:
	$(DOCKER_COMPOSE) stop

# Define the target start
start:
	$(DOCKER_COMPOSE) start
