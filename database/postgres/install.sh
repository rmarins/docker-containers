#!/bin/sh

# Create container
echo "Creating PostgreSQL container ..."
docker build --rm -q -t rmarins/postgresql ./docker

if [ $? -eq 0 ]; then
    echo "Container build"
else
    echo "Error building container"
fi


