#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Build the Docker image
echo "Building DeepCRISTL Docker image..."
docker build -t garagecollection/deepcristl:1.0 -f ./dockerfiles/DeepCRISTL_dockerfile .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\nDeepCRISTL Docker image built successfully!"
    echo -e "\nTo run DeepCRISTL:"
    echo "docker run --rm -it -v $(pwd)/output:/app/output garagecollection/deepcristl:1.0 python /app/CRISPROn/tool.py"
    echo ""
else
    echo "Error: Failed to build Docker image"
    exit 1
fi
