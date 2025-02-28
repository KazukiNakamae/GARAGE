#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Build the Docker image
echo "Building getCRISPRY Docker image..."
docker build -t garagecollection/getcrispry:1.0 -f ./dockerfiles/getCRISPRY_dockerfile .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "CRISPRY Docker image built successfully!"
    echo -e "\nTo run getCRISPRY:"
    echo "docker run --rm -it -v $(pwd)/output:/app/output garagecollection/getcrispry:1.0 python"
    echo ""
    echo "Example: https://github.com/asistradition/getCRISPRY/blob/master/tests/core_test.py"
else
    echo "Error: Failed to build Docker image"
    exit 1
fi
