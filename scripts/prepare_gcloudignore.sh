#!/bin/bash
set -e

GCLOUDIGNORE_PATH="out/.gcloudignore"

# Copy custom .gcloudignore file if provided and exists
if [[ -n "$1" && -e "$1" ]]; then
  cp "$1" "$GCLOUDIGNORE_PATH"
else
  # Generate default .gcloudignore content
  cat > "$GCLOUDIGNORE_PATH" <<EOF
.gcloudignore
.git
.gitignore
README.md
.turbo
node_modules
EOF
fi
