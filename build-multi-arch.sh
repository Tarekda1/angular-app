#!/bin/bash

IMAGE_NAME="${DOCKER_IMAGE}" # Or specify it here
IMAGE_TAG="${DOCKER_TAG}"

# 1. Build for amd64 (your staging server's architecture)
docker build --platform linux/amd64  -t "${IMAGE_NAME}:${IMAGE_TAG}" .

# 2. Build for other architectures if needed (e.g., arm64)
# docker build -t "${IMAGE_NAME}:${IMAGE_TAG}-arm64" .

# 3. Create and push the manifest (important!)
#docker manifest create "${IMAGE_NAME}:${IMAGE_TAG}" \
#    --amend "${IMAGE_NAME}:${IMAGE_TAG}-amd64" \
    # --amend "${IMAGE_NAME}:${IMAGE_TAG}-arm64"  # Uncomment if you built for arm64

#docker manifest push "${IMAGE_NAME}:${IMAGE_TAG}"

docker  push "${IMAGE_NAME}:${IMAGE_TAG}"

# 4. (Optional) Inspect the manifest
docker manifest inspect "${IMAGE_NAME}:${IMAGE_TAG}"