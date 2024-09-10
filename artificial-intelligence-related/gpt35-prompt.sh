# Set API Endpoint

export OPENAI_API_ENDPOINT="https://api.openai.com/v1/chat/completions"

# Pass in the message from the command line as an argument

MESSAGE=$1

# Store response in variable

RESPONSE=$(curl --insecure https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "'"$MESSAGE"'"}
    ],
    "temperature": 0.5
  }'| jq '.choices[] | .message.content')

# Print response

echo $RESPONSE


