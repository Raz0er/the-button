#!/bin/bash

# Script parameters
IMAGE_NAME=$1
TAG=$2
EC2_HOST=$3
EC2_USER=$4
ENV_NAME=$5

echo "Starting deployment of image $IMAGE_NAME:$TAG to server $EC2_HOST in $ENV_NAME environment"

# Preparing .env.prod file with appropriate variables
sed -i "s/your_dockerhub_username/$(echo $IMAGE_NAME | cut -d '/' -f 1)/" .env.prod
sed -i "s/latest/$TAG/" .env.prod
sed -i "s/localhost,127.0.0.1/localhost,127.0.0.1,$EC2_HOST/" .env.prod

echo "Deployment files have been prepared"
echo "Deploying application..."

# Copying files to the server
scp -i ~/.ssh/deploy_key .env.prod $EC2_USER@$EC2_HOST:~/.env
scp -i ~/.ssh/deploy_key docker-compose.yml $EC2_USER@$EC2_HOST:~/
# Running the application on the server
ssh -i ~/.ssh/deploy_key $EC2_USER@$EC2_HOST "cd ~/ && docker compose up -d"

echo "Deployment completed successfully"
