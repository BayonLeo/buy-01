#!/bin/sh
set -e
# deploy2.sh: improved wrapper to deploy the repo's docker-compose stack
# Usage: ./deploy/deploy2.sh <image-tag> <env>

TAG="$1"
ENV="$2"

echo "Deploy script starting. TAG=${TAG} ENV=${ENV}"

# Create .env from .env.example if it doesn't exist (for CI/CD)
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  echo "Creating .env from .env.example with demo values"
  cp .env.example .env
  # Set demo values for CI/CD
  sed -i 's/^JWT_SECRET=.*/JWT_SECRET=demo-jwt-secret-for-ci-cd-only/' .env
  sed -i 's/^INTERNAL_TOKEN=.*/INTERNAL_TOKEN=demo-internal-token-for-ci-cd/' .env
fi

# Export IMAGE_TAG for use in docker-compose environment variable substitution if compose files reference it
export IMAGE_TAG="${TAG}"

# Optional: load environment-specific .env file if present
if [ -f ".env.${ENV}" ]; then
  echo "Loading environment file .env.${ENV}"
  set -a; . ".env.${ENV}"; set +a
fi

echo "Cleaning up any existing buy-01-pipeline containers (from previous builds)"
docker rm -f $(docker ps -aq --filter "name=buy-01-pipeline") 2>/dev/null || true

echo "Bringing down existing stack (if any)"
docker compose down --remove-orphans || true

echo "Starting stack with docker compose (build if necessary)"
docker compose up -d --build

# Save the tag for possible rollbacks
mkdir -p deploy
echo "${TAG}" > deploy/previous_tag.txt

echo "Deployment complete"
docker compose ps
