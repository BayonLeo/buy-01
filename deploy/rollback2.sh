#!/bin/sh
set -e
# rollback2.sh: attempt to rollback using saved previous_tag
# Usage: ./deploy/rollback2.sh <env>

ENV="$1"

PREV_FILE="deploy/previous_tag.txt"

if [ ! -f "${PREV_FILE}" ]; then
  echo "No previous tag file (${PREV_FILE}) found. Cannot rollback automatically."
  exit 0
fi

PREV_TAG=$(cat "${PREV_FILE}" | tr -d '\n')
echo "Found previous tag: ${PREV_TAG}"

if [ -n "${DOCKER_REGISTRY}" ]; then
  echo "Attempting to pull previous images from registry ${DOCKER_REGISTRY}"
  docker pull ${DOCKER_REGISTRY}/user-service:${PREV_TAG} || true
  docker pull ${DOCKER_REGISTRY}/product-service:${PREV_TAG} || true
  docker pull ${DOCKER_REGISTRY}/media-service:${PREV_TAG} || true
  # Optionally retag to local names if your compose uses local image names
  docker tag ${DOCKER_REGISTRY}/user-service:${PREV_TAG} user-service:${PREV_TAG} || true
  docker tag ${DOCKER_REGISTRY}/product-service:${PREV_TAG} product-service:${PREV_TAG} || true
  docker tag ${DOCKER_REGISTRY}/media-service:${PREV_TAG} media-service:${PREV_TAG} || true
  echo "Bringing down current stack"
  docker-compose down --remove-orphans || true
  echo "Starting stack with previous images"
  docker-compose up -d
  echo "Rollback attempted with tag ${PREV_TAG}"
else
  echo "DOCKER_REGISTRY is not set. Automatic rollback from registry unavailable."
  echo "If you have the previous images locally, set IMAGE_TAG to ${PREV_TAG} and run docker-compose up -d."
fi
