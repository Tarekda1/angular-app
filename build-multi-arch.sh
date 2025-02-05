#!/bin/bash

IMAGE_NAME="${DOCKER_IMAGE}"
IMAGE_TAG="${DOCKER_TAG}"

# 1. Initialize buildx for multi-architecture builds
docker buildx create --use --name multiarch-builder || true

# 2. Build and push for linux/amd64 explicitly
docker buildx build \
    --platform linux/amd64 \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --push \
    .

# 3. (Optional) For true multi-architecture support, add more platforms:
# docker buildx build \
#     --platform linux/amd64,linux/arm64 \
#     -t "${IMAGE_NAME}:${IMAGE_TAG}" \
#     --push \
#     .

# 4. Verify manifest (should show amd64 now)
docker manifest inspect "${IMAGE_NAME}:${IMAGE_TAG}"