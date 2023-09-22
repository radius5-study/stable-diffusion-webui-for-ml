.PHONY: build up down bash
include .env
include .env.local

BUILD_UID_LOCAL=$(shell id -u ${USER})
BUILD_GID_LOCAL=$(shell id -g ${USER})
LOCAL_HTTP_URL=http://localhost:${PORT}

# local
build_local:
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

# deploy
build:
	docker compose build --progress=plain

down:
	docker compose down

DEV_GCS_BUCKET_NAME=${GCS_BUCKET_NAME}-dev
DEV_GOOGLE_APPLICATION_CREDENTIALS=$(shell echo ${GOOGLE_APPLICATION_CREDENTIALS} | sed 's/\.json/-dev\.json/')
## dev
up_dev:
	GCS_BUCKET_NAME=${DEV_GCS_BUCKET_NAME} \
		GOOGLE_APPLICATION_CREDENTIALS=${DEV_GOOGLE_APPLICATION_CREDENTIALS} \
		docker compose up

bash_dev:
	GCS_BUCKET_NAME=${DEV_GCS_BUCKET_NAME} \
		GOOGLE_APPLICATION_CREDENTIALS=${DEV_GOOGLE_APPLICATION_CREDENTIALS} \
		docker compose run \
				--rm -p ${PORT}:${PORT} \
				-v ${PWD}/keys:/home/${DOCKER_USERNAME}/${API_DIR}/keys \
				api bash

## prod
up:
	GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS} \
		docker compose up

bash:
	GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS} \
		docker compose run \
				--rm -p ${PORT}:${PORT} \
				-v ${PWD}/keys:/home/${DOCKER_USERNAME}/${API_DIR}/keys \
				api bash
