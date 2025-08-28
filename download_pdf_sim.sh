#!/bin/bash
set -e

# --- CONFIG ---
DEST_DIR="$HOME/Downloads/pdfs"
CONTAINER_NAME="cups"
PDF_DIR="/output/pdf"

mkdir -p "$DEST_DIR"

# 1. Find container ID
CID=$(docker ps --filter "name=$CONTAINER_NAME" --format "{{.ID}}")
if [ -z "$CID" ]; then
  echo "No running container found with name containing '$CONTAINER_NAME'"
  exit 1
fi

# 2. Find latest PDF inside container
LATEST_FILE=$(docker exec "$CID" bash -c "ls -t $PDF_DIR/*.pdf 2>/dev/null | head -n 1")
if [ -z "$LATEST_FILE" ]; then
  echo "No PDF found in $PDF_DIR inside container"
  exit 1
fi

# 3. Copy it out
docker cp "$CID:$LATEST_FILE" "$DEST_DIR/"

echo "Copied $(basename "$LATEST_FILE") → $DEST_DIR/"

