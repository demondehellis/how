#!/bin/bash

# Define request parameters
ENDPOINT='https://api.openai.com/v1/responses'
MODEL="${HOW_TO_MODEL:-gpt-6-luna}"

# Check if jq is installed
command -v jq &> /dev/null || { echo "Please install jq to use this script."; exit 1; }

# Check OPENAI_API_KEY is set
[[ -z "$OPENAI_API_KEY" ]] && { echo "Please set the OPENAI_API_KEY environment variable."; exit 1; }

# Get the current OS
OS=$(uname)

# Get the current shell (prefer the shell that invoked this script, since the
# script itself always runs under bash; fall back to the login shell)
CURRENT_SHELL=$(ps -o comm= -p "$PPID" 2>/dev/null | sed 's|.*/||; s|^-||')
case "$CURRENT_SHELL" in
  bash|zsh|fish|sh|dash|ksh|mksh|tcsh|csh|nu|elvish|xonsh) ;;
  *) CURRENT_SHELL=$(basename "${SHELL:-unknown}") ;;
esac

# Combine all command-line arguments into a single string
QUESTION="$@"

# Set the prefix, allowing it to be overridden by HOW_TO_PREFIX environment variable
PREFIX="${HOW_TO_PREFIX:-Reply using one-line bash command without code block. Question: How}"

# Prepare the full prompt with shell and OS included
PROMPT="$PREFIX $QUESTION? In $CURRENT_SHELL, $OS."

# Prepare the JSON payload for the request
DATA=$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT" \
  '{model: $model, input: $prompt}')

# Send the request to OpenAI API
RESULT=$(curl --silent --show-error --location --insecure --request POST "$ENDPOINT" \
  --header "Authorization: Bearer $OPENAI_API_KEY" \
  --header 'Content-Type: application/json' \
  --data-raw "$DATA" \
  --write-out $'\n%{http_code}') || { echo "OpenAI API request failed." >&2; exit 1; }

HTTP_STATUS=${RESULT##*$'\n'}
RESPONSE=${RESULT%$'\n'*}

if [[ "$HTTP_STATUS" != 2?? ]]; then
  ERROR_MESSAGE=$(echo "$RESPONSE" | jq -r '.error.message // empty' 2>/dev/null)
  echo "OpenAI API error ($HTTP_STATUS): ${ERROR_MESSAGE:-Unexpected response}" >&2
  exit 1
fi

# Extract text from the Responses API output
MESSAGE_CONTENT=$(echo "$RESPONSE" | jq -r '[.output[]?.content[]? | select(.type == "output_text") | .text] | join("")')

# Print the command to terminal
echo "$MESSAGE_CONTENT"

# Copy the command to clipboard if pbcopy is available
command -v pbcopy &> /dev/null && echo "$MESSAGE_CONTENT" | pbcopy
