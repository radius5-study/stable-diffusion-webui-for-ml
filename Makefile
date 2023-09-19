.PHONY: build up down bash
include .env

BUILD_UID_LOCAL=$(shell id -u ${USER})
BUILD_GID_LOCAL=$(shell id -g ${USER})
LOCAL_HTTP_URL=http://localhost:${PORT}

# local
build_local:
	bash ./pre-download.sh
	docker compose \
		-f docker-compose.local.yml \
		build \
			--progress=plain \
			--build-arg USER_UID=${BUILD_UID_LOCAL} \
			--build-arg USER_GID=${BUILD_GID_LOCAL}

up_local:
	docker compose -f docker-compose.local.yml up

down_local:
	docker compose -f docker-compose.local.yml down

bash_local:
	docker compose \
		-f docker-compose.local.yml \
		run \
			--rm -p ${PORT}:${PORT} \
			-v ${PWD}/keys:/home/${DOCKER_USERNAME}/${API_DIR}/keys \
			api bash

curl_post:
	curl -XPOST -H"Content-Type: application/json" \
		-d'{"prompt": ${TEST_PROMPT}, "steps": 20}' \
		${LOCAL_HTTP_URL}/sdapi/v1/txt2img

python_post:
	PORT=${PORT} TEST_PROMPT=${TEST_PROMPT} python post.py

# prod
build:
	docker compose build --progress=plain

up:
	docker compose up

down:
	docker compose down

bash:
	docker compose run \
			--rm -p ${PORT}:${PORT} \
			-v ${PWD}/keys:/home/${DOCKER_USERNAME}/${API_DIR}/keys \
			api bash
