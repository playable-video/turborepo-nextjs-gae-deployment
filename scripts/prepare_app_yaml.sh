#!/bin/bash
set -e

APP_YAML_PATH="out/app.yaml"

# Copy custom app.yaml if provided and exists
if [[ -n "$1" && -e "$1" ]]; then
  cp "$1" "$APP_YAML_PATH"
else
  # Generate default app.yaml
  cat > "$APP_YAML_PATH" <<EOF
env: flex
runtime: nodejs
runtime_config:
  operating_system: "ubuntu22"
  runtime_version: "20"
handlers:
  - url: /.*
    secure: always
    script: auto
EOF
fi

# Add service ID if provided
if [[ -n "$2" ]]; then
  echo "service: $2" >> "$APP_YAML_PATH"
fi
