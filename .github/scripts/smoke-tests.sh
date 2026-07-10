#!/bin/bash

# Script parameters
APP_URL=$1
MAX_RETRIES=10
RETRY_INTERVAL=5

echo "Starting smoke tests for $APP_URL"

# Main page availability test
success=false
for i in $(seq 1 $MAX_RETRIES); do
  echo "Try $i of $MAX_RETRIES: checking main page availability..."
  
  response=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL)
  
  if [ "$response" = "200" ]; then
    echo "Main page is available (HTTP 200)"
    success=true
    break
  else
    echo "Main page is not available (HTTP $response)"
    echo "Waiting $RETRY_INTERVAL seconds before next attempt..."
    sleep $RETRY_INTERVAL
  fi
done

if [ "$success" = false ]; then
  echo "Main page availability test failed after $MAX_RETRIES attempts"
  exit 1
fi

# Ping function test
success=false
for i in $(seq 1 $MAX_RETRIES); do
  echo "Try $i of $MAX_RETRIES: checking ping endpoint..."
  
  response=$(curl -s $APP_URL/ping/)
  
  if [[ $response == *"pong"* ]]; then
    echo "Ping endpoint is working correctly, response contains 'pong'"
    success=true
    break
  else
    echo "Invalid response from ping endpoint: $response"
    echo "Waiting $RETRY_INTERVAL seconds before next attempt..."
    sleep $RETRY_INTERVAL
  fi
done

if [ "$success" = false ]; then
  echo "Ping endpoint test failed after $MAX_RETRIES attempts"
  exit 1
fi

echo "All smoke tests completed successfully!"
exit 0
