#!/usr/bin/env sh

# Convert a Markdown file to .docx
# Rule 1: Use Pandoc only where necessary

# Figure out where everything is
SCRIPT="$(realpath "$0")"
SCRIPT_PATH="$(dirname "$SCRIPT")"
FILTERS_PATH="$(realpath "$SCRIPT_PATH/..")"
export LUA_PATH
LUA_PATH="$FILTERS_PATH/?.lua;;"
PANDOC_TEMPLATES="$(dirname "$SCRIPT_PATH")"
SHUNN_SHORT_STORY_DIR="$PANDOC_TEMPLATES/shunn/short"

if (( $# > 0 )); then
  if [ -f "$1" ];then
      MDFILE="$1"
      OUTFILE=$(basename "${MDFILE%.*}.docx")
  else
      echo "$1 not found"
      exit 10
  fi
else
  echo "Usage:" $(basename "$0") "filename.md"
  exit 1
fi

# Create a temporary data directory
echo "Creating temporary directory."
export PANDOC_DATA_DIR
PANDOC_DATA_DIR="$(mktemp -d)"
echo "Directory created: $PANDOC_DATA_DIR"

# Prep the template and reference directories
echo "Extracting $SHUNN_SHORT_STORY_DIR/template.docx to temporary directory."
unzip -ao "$SHUNN_SHORT_STORY_DIR/template.docx" -d "$PANDOC_DATA_DIR/template" > /dev/null
unzip -ao "$SHUNN_SHORT_STORY_DIR/template.docx" -d "$PANDOC_DATA_DIR/reference" > /dev/null
echo "Files extracted."

# Run pandoc
echo "Running Pandoc."
if pandoc \
  --from=markdown \
  --to=docx \
  --lua-filter="$SHUNN_SHORT_STORY_DIR/shunnshort.lua" \
  --data-dir="$PANDOC_DATA_DIR" \
  --output="$OUTFILE" \
  --metadata-file="$SHUNN_META" \
  "$MDFILE"; then
  echo "Pandoc completed successfully."
  ECODE=0
else
  echo "Pandoc FAILED."
  ECODE=10
fi

# Clean up the temporary directory
rm -rf "$PANDOC_DATA_DIR"
exit $ECODE