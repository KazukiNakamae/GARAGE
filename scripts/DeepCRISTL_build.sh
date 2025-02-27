#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Build the Docker image
echo "Building DeepCRISTL Docker image..."
docker build -t deepcristl:latest -f ./dockerfiles/DeepCRISTL_dockerfile .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\nDeepCRISTL Docker image built successfully!"
    echo -e "\nTo run DeepCRISTL:"
    echo "docker run -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    deepcristl:latest"
    echo -e "\nTo run a specific Python script:"
    echo "docker run -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    deepcristl:latest \\"
    echo "    python your_script.py"
    echo -e "\nTo start an interactive shell:"
    echo "docker run -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    deepcristl:latest \\"
    echo "    /bin/bash"
else
    echo "Error: Failed to build Docker image"
    exit 1
fi
