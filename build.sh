#!/bin/bash

# Exit on any error
set -e

# Use Node v25.0.0 Docker image to build the project
docker run --rm \
  -v "$(pwd)":/app \
  -w /app \
  node:25.0.0-alpine \
  sh -c "npm install && npm run build"

# Build the Nginx Docker image
docker build -t goff-playground .

# Clean up
rm -rf dist

echo "Build completed successfully!"
echo "Docker image 'goff-playground' is ready to use."