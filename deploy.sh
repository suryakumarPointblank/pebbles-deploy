#!/bin/bash
set -e

echo "==> Pulling latest code..."
cd /root/pebbles-backend
git fetch origin
git checkout deploy-ferring
git reset --hard origin/deploy-ferring

echo "==> Building Docker image..."
docker build -t pebbles-backend:latest -f /root/pebbles-deploy/Dockerfile /root/pebbles-backend/

echo "==> Restarting container..."
docker rm -f pebbles-backend || true
docker run -d \
    --name pebbles-backend \
    --restart unless-stopped \
    -p 5000:5000 \
    --network pebbles-network \
    --env-file /root/pebbles-deploy/.env \
    pebbles-backend:latest

echo "==> Waiting for container to start..."
sleep 5
docker logs pebbles-backend --tail 20

echo "==> Deploy complete."
