# Text To Bash CLI Tool

A minimalistic bash script that uses OpenAI's GPT to convert natural language to bash commands.

## Requirements
- `curl` for making API requests
- `jq` for parsing JSON responses
- `pbcopy` for copying output to clipboard
- OpenAI API key

## Setup

1. Add your `OPENAI_API_KEY` to environment variables.
2. Make sure the script executable: `chmod +x ./how`.
3. Make link to the script: `ln -s ./how /usr/local/bin/how`

## Usage

```bash
# in your terminal:
how to find the biggest file in current directory

# output:
find . -type f -exec du -h {} + | sort -rh | head -n 1

# output was copied to your clipboard using pbcopy
```