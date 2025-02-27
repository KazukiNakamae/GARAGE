#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if NVIDIA Docker runtime is installed
if ! docker info | grep -i "nvidia" &> /dev/null; then
    echo "Warning: NVIDIA Docker runtime not found. GPU support may not be available."
    echo "To enable GPU support, install nvidia-docker2"
fi

# Build the Docker image
echo "Building DeepGuide Docker image..."
docker build -t deepguide:latest -f ./dockerfiles/deepguide-reborn_dockerfile .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\nDeepGuide Docker image built successfully!"
    echo -e "\nTo run DeepGuide with GPU support:"
    echo "docker run --gpus all -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    deepguide:latest"
    echo -e "\nTo run a specific Python script:"
    echo "docker run --gpus all -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    deepguide:latest \\"
    echo "    python src/your_script.py"
    echo -e "\nTo start an interactive shell:"
    echo "docker run --gpus all -it --rm \\"
    echo "    -v \$(pwd)/output:/app/output \\"
    echo "    deepguide:latest \\"
    echo "    /bin/bash"
else
    echo "Error: Failed to build Docker image"
    exit 1
fi
