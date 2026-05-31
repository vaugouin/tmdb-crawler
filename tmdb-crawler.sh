#!/bin/bash

# Check if the tmdb-crawler Docker container is running
if [ $(docker ps -q -f name=tmdb-crawler) ]; then
    echo "tmdb-crawler Docker container is already running."
else
    # Start the tmdb-crawler container if it is not running
    # Create the per-stack shared_data subdir if it doesn't exist.
    # The crawler now reads its own files client-side (LOAD DATA LOCAL INFILE),
    # so it no longer needs to mount the shared_data root — a dedicated subdir
    # keeps its (transient) files isolated from other stacks.
    mkdir -p $HOME/docker/shared_data/tmdb-crawler
    cd $HOME/docker/tmdb-crawler
    docker build -t tmdb-crawler-python-app .
    # docker run -it --rm --network="host" --name tmdb-crawler --env-file /home/debian/docker/tmdb-crawler/.env -v $HOME/docker/shared_data/tmdb-crawler:/shared tmdb-crawler-python-app
    docker run -d --rm --network="host" --name tmdb-crawler --env-file /home/debian/docker/tmdb-crawler/.env -v $HOME/docker/shared_data/tmdb-crawler:/shared tmdb-crawler-python-app
    echo "tmdb-crawler Docker container started."
fi
