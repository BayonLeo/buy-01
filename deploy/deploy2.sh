#!/bin/sh
set -e
# deploy2.sh: improved wrapper to deploy the repo's docker-compose stack
# Usage: ./deploy/deploy2.sh <image-tag> <env>

TAG="$1"
ENV="$2"

echo "Deploy script starting. TAG=${TAG} ENV=${ENV}"

# Export IMAGE_TAG for use in docker-compose environment variable substitution if compose files reference it
export IMAGE_TAG="${TAG}"

# Optional: load environment-specific .env file if present
if [ -f ".env.${ENV}" ]; then
  echo "Loading environment file .env.${ENV}"
  set -a; . ".env.${ENV}"; set +a
fi

echo "Bringing down existing stack (if any)"
docker-compose down --remove-orphans || true

echo "Starting stack with docker-compose (build if necessary)"
docker-compose up -d --build

# Save the tag for possible rollbacks
mkdir -p deploy
echo "${TAG}" > deploy/previous_tag.txt

echo "Deployment complete"
docker-compose ps
