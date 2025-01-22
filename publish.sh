#!/bin/bash

OUTPUT_DIR="fake_build_output"
PAYLOAD_FILE="payload.json"

# Start the JSON payload
echo '{ "game": { "name": "anon game", "assets": [' > $PAYLOAD_FILE

# Iterate over all files in the directory
FIRST=true
for FILE in "$OUTPUT_DIR"/*; do
  BASE64_DATA="data:application/octet-stream;base64,$(base64 -i "$FILE")"
  FILENAME=$(basename "$FILE")
  
  # Add a comma before each entry except the first
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    echo ',' >> $PAYLOAD_FILE
  fi

  # Append the asset object to the JSON payload
  cat <<EOF >> $PAYLOAD_FILE
    {
      "filename": "$FILENAME",
      "data": "$BASE64_DATA"
    }
EOF
done

# Close the JSON payload
echo '  ] } }' >> $PAYLOAD_FILE

# POST to Final Parsec
curl -X POST https://www.finalparsec.com/api/games \
-H "Content-Type: application/json" \
-d @payload.json
