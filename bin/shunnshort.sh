#!/usr/bin/env bash

# Rule 1: Do only what's necessary in Pandoc

# Figure out where everything is
SCRIPT=$(realpath $0)
SCRIPT_PATH=$(dirname $SCRIPT)
PANDOC_TEMPLATES_HOME=$(dirname $SCRIPT_PATH)
SHUNN_SHORT_STORY_DIR="$PANDOC_TEMPLATES_HOME/shunn/short"

# Create a temporary data directory
echo "Creating temporary directory."
export PANDOC_DATA_DIR=$(mktemp -d)
echo "Directory created: $PANDOC_DATA_DIR"

# Copy template and reference directories
echo "Copying $SHUNN_SHORT_STORY_DIR/template/ to $PANDOC_DATA_DIR/reference/."
cp --recursive $SHUNN_SHORT_STORY_DIR/template -d $PANDOC_DATA_DIR/reference
echo "Template copied."

# Run pandoc
echo "Running Pandoc."
pandoc $1 \
  --from markdown \
  --to docx \
  --lua-filter $SHUNN_SHORT_STORY_DIR/shunnshort.lua \
  --data-dir $PANDOC_DATA_DIR \
  --output $2
echo "Pandoc completed successfully."

# Clean up the temporary directory
echo "Removing $PANDOC_DATA_DIR"
rm -rf $PANDOC_DATA_DIR
echo "Done."
