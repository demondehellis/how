# Natural Language to Bash

This script transforms natural language input into bash commands, allowing you to interact with your terminal more intuitively. 
Powered by OpenAI's GPT API.

## Requirements
- `curl` for making API requests
- `jq` for parsing JSON responses
- `pbcopy` for copying output to clipboard (optional)
- OpenAI API key

## Setup

1. Add your `OPENAI_API_KEY` to environment variables (e.g. in your `.bashrc` or `.zshrc`).
2. Make sure the script executable: `chmod +x /path/to/how.sh`.
3. Make link to the script: `ln -s /path/to/how.sh /usr/local/bin/how`

## Usage

Type `how` in your terminal followed by a question or command. The script will return a bash command:

```bash
# in your terminal:
how to find the biggest file in current directory

# output:
find . -type f -exec du -h {} + | sort -rh | head -n 1

# output is also copied to clipboard
# paste and run it with `Cmd + V` and `Enter`
```