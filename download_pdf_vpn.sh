#!/bin/bash
set -e

REMOTE_USER="rr"
REMOTE_HOST="100.64.4.144"
REMOTE_TMP="/home/rr"
DEST_DIR="$HOME/Downloads/pdfs"
PDF_DIR="/tmp"

mkdir -p "$DEST_DIR"

#Repeatedly it asks for password

# 1. Get Docker container ID of wms_server (column 5 from dectl ps)
CID=$(ssh ${REMOTE_USER}@${REMOTE_HOST} "dectl ps | grep wms_server | awk '{print \$5}'")
if [ -z "$CID" ]; then
  echo "No wms_server container found on $REMOTE_HOST"
  exit 1
fi
echo "Using container: $CID"

# 2. Find latest PDF inside container
LATEST_FILE=$(ssh ${REMOTE_USER}@${REMOTE_HOST} \
  "docker exec $CID bash -c 'ls -t $PDF_DIR/*.pdf 2>/dev/null | head -n 1'")

if [ -z "$LATEST_FILE" ]; then
  echo "No PDF found in $PDF_DIR inside container"
  exit 1
fi

FILENAME=$(basename "$LATEST_FILE")

# 3. Copy PDF from container → remote home folder
ssh ${REMOTE_USER}@${REMOTE_HOST} \
  "docker cp $CID:$LATEST_FILE $REMOTE_TMP/$FILENAME"

# 4. Copy PDF from remote → local Downloads
scp ${REMOTE_USER}@${REMOTE_HOST}:$REMOTE_TMP/$FILENAME "$DEST_DIR/"

echo "Copied $FILENAME → $DEST_DIR/"




