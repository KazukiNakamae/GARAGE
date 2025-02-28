#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Build the Docker image
echo "Building CRISPR-BERT Docker image..."
docker build -t garagecollection/crispr-bert:1.0 -f ./dockerfiles/CRISPR-BERT_dockerfile .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\nCRISPR-BERT Docker image built successfully!"
    echo -e "\nTo run CRISPR-BERT:"
    echo "docker run -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    crispr-bert:latest"
    echo -e "\nTo run a specific script:"
    echo "docker run -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    crispr-bert:latest \\"
    echo "    python model_test.py"
    echo -e "\nTo start an interactive shell:"
    echo "docker run -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    crispr-bert:latest \\"
    echo "    /bin/bash"
else
    echo "Error: Failed to build Docker image"
    exit 1
fi

