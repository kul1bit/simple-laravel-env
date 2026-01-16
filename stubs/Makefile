DOCP_CMD = docker compose
APP_CONTAINER = container-name
APP_IMAGE = app-image
DOCKER_ENV = .docker.env

start: build composer-install up

build:
        @echo "Build docker images..."
        cp .docker.env.example $(DOCKER_ENV)
        $(DOCP_CMD) --env-file $(DOCKER_ENV) build

composer-install:
        @echo "Run composer..."
        cp .env.example .env
        docker run --rm \
                -v $(PWD):/var/www \
                -w /var/www \
                $(APP_IMAGE) \
                composer install
        '

up:
        @echo "Run project..."
        $(DOCP_CMD) --env-file $(DOCKER_ENV) up -d

down:
        @echo "Stop project..."
        $(DOCP_CMD) down%                
