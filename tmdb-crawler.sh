#!/bin/bash

# Check if the tmdb-crawler Docker container is running
if [ $(docker ps -q -f name=tmdb-crawler) ]; then
    echo "tmdb-crawler Docker container is already running."
else
    # Start the tmdb-crawler container if it is not running
    # Create shared_data folder if it doesn't exist
    mkdir -p $HOME/docker/shared_data
    cd $HOME/docker/tmdb-crawler
    docker build -t tmdb-crawler-python-app .
    # docker run -it --rm --network="host" --name tmdb-crawler -v $HOME/docker/shared_data:/shared tmdb-crawler-python-app
    docker run -d --rm --network="host" --name tmdb-crawler -v $HOME/docker/shared_data:/shared tmdb-crawler-python-app
    echo "tmdb-crawler Docker container started."
fi
