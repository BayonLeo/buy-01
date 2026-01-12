#!/bin/sh
set -e
# rollback.sh: placeholder for rolling back a deployment
# Usage: ./deploy/rollback.sh <env>

ENV="$1"

echo "Rollback script triggered for ENV=${ENV}"

# Example strategy (customize):
# - Use docker-compose with a previous docker-compose.override or a saved compose file
# - Pull and redeploy a previous image tag
# This script is a placeholder. Implement your rollback policy here.

echo "No rollback policy implemented. Exiting with status 0."
exit 0
