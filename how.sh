#!/bin/bash

# Define request parameters
ENDPOINT='https://api.openai.com/v1/chat/completions'
MODEL="${HOW_TO_MODEL:-gpt-4o-mini}" # Default to gpt-4o-mini

# Check if jq is installed
command -v jq &> /dev/null || { echo "Please install jq to use this script."; exit 1; }

# Check OPENAI_API_KEY is set
[[ -z "$OPENAI_API_KEY" ]] && { echo "Please set the OPENAI_API_KEY environment variable."; exit 1; }

# Get the current OS
OS=$(uname)

# Combine all command-line arguments into a single string
QUESTION="$@"
QUESTION="${QUESTION//\"/\\\"}" # Escape double quotes

# Set the prefix, allowing it to be overridden by HOW_TO_PREFIX environment variable
PREFIX="${HOW_TO_PREFIX:-Reply using one-line bash command without code block. Question: How}"

# Prepare the full prompt with OS version included
PROMPT="$PREFIX $QUESTION? in $OS"

# Prepare the JSON payload for the request
DATA="{\"model\":\"$MODEL\",\"temperature\":0,\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}]}"

# Send the request to OpenAI API
RESPONSE=$(curl --silent --location --insecure --request POST "$ENDPOINT" \
  --header "Authorization: Bearer $OPENAI_API_KEY" \
  --header 'Content-Type: application/json' \
  --data-raw "$DATA")

# Extract the message content from the response
MESSAGE_CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

# Print the command to terminal
echo "$MESSAGE_CONTENT"

# Copy the command to clipboard if pbcopy is available
command -v pbcopy &> /dev/null && echo "$MESSAGE_CONTENT" | pbcopy
