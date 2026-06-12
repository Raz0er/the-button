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

Zamień krok deploy-to-production w workflow na prawdziwe wdrożenie:

  deploy-to-production:
    needs: deploy-to-dev
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3

      - name: Install SSH Key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          
      - name: Adding Known Hosts
        run: |
          ssh-keyscan  ${{ secrets.EC2_HOST }} >> ~/.ssh/known_hosts
          
      - name: Prepare deployment
        run: |
          chmod +x  ./.github/scripts/deploy.sh
          
      - name: Deploy to EC2
        env:
          IMAGE_NAME: ${{ secrets.DOCKER_USERNAME }}/the-button
          TAG: latest
          EC2_HOST: ${{ secrets.EC2_HOST }}
          EC2_USER: ${{ secrets.EC2_USER }}
          ENV_NAME: production
        run: |
          echo "Starting deployment to EC2..."
          ./.github/scripts/deploy.sh $IMAGE_NAME $TAG $EC2_HOST $EC2_USER $ENV_NAME


