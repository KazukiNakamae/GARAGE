#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Check if NVIDIA Docker runtime is available
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${RED}Warning: NVIDIA GPU not detected. The container will run without GPU support.${NC}"
fi

# Image name and tag
IMAGE_NAME="crispr-ip"
TAG="latest"

echo -e "${GREEN}Building CRISPR-IP Docker image...${NC}"

# Build the Docker image
docker build -t ${IMAGE_NAME}:${TAG} -f ./dockerfiles/CRISPR-IP_dockerfile .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    echo ""
    echo "You can now run the container with:"
    echo "docker run --gpus all -it --rm \\"
    echo "    -v \$(pwd)/example_saved:/app/example_saved \\"
    echo "    ${IMAGE_NAME}:${TAG}"
    echo ""
    echo "To run a specific example:"
    echo "docker run --gpus all -it --rm \\"
    echo "    -v \$(pwd)/example_saved:/app/example_saved \\"
    echo "    ${IMAGE_NAME}:${TAG} \\"
    echo "    python3 example-train-CRISPR-IP.py"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
