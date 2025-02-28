#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Build the Docker image
echo "Building CRISPert Docker image..."
docker build -t garagecollection/crisprert:1.0 -f ./dockerfiles/CRISPert_dockerfile .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "CRISPert Docker image built successfully!"
    echo -e "\nTo run CRISPert test:"
    echo "docker run --rm -it -v $(pwd)/output:/app/output garagecollection/crisprert:1.0"
    echo ""
else
    echo "Error: Failed to build Docker image"
    exit 1
fi
