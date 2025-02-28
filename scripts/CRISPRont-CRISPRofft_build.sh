#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Build the Docker image
echo "Building CRISPRont-CRISPRofft Docker image..."
docker build . --tag garagecollection/crispront_crisprofft:1.0 -f ./dockerfiles/CRISPRont-CRISPRofft_dockerfile

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "CRISPRont-CRISPRofft Docker image built successfully!"
    echo -e "\nTo run CRISPRont-CRISPRofft:"
    echo "docker run --rm -it -v $(pwd)/output:/app/output garagecollection/crispront_crisprofft:1.0 python /app/crispr/crispr_ont_prediction.py [options]"
    echo "docker run --rm -it -v $(pwd)/output:/app/output garagecollection/crispront_crisprofft:1.0 python /app/crispr/crispr_offt_prediction.py [options]"
    echo ""
else
    echo "Error: Failed to build Docker image"
    exit 1
fi
