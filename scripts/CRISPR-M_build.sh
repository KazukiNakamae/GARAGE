#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Build the Docker image
echo "Building DeepCRISTL Docker image..."
docker build -t garagecollection/crispr-m:1.0 -f ./dockerfiles/CRISPR-M_dockerfile .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "CRISPR-M Docker image built successfully!"
    echo -e "\nTo run CRISPR-M test:"
    echo "docker run --rm -it -v $(pwd)/output:/app/output garagecollection/crispr-m:1.0 python /app/CRISPR-M/codes/mnist_test.py"
    echo ""
else
    echo "Error: Failed to build Docker image"
    exit 1
fi
