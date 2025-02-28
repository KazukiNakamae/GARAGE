#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


docker build -f ./dockerfiles/GuideVar_dockerfile --tag garagecollection/guidevar:1.0 .


if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    echo ""
    echo "Run the GuideVar-on command line interface (CLI) with the command in the terminal:"
    echo "docker run --rm -v ${PWD}/:/app/output -w /app/output garagecollection/guidevar:1.0 GuideVar-on [options]"
    echo ""
    echo "Run the GuideVar-off command line interface (CLI) with the command in the terminal:"
    echo "docker run --rm -v ${PWD}/:/app/output -w /app/output garagecollection/guidevar:1.0 GuideVar-off [options]"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
