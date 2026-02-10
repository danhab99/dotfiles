#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --major|--minor|--patch \"arbitrary name\""
  exit 1
}

# Parse flags
KIND=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --major|--minor|--patch)
      if [[ -n "$KIND" ]]; then
        echo "Error: only one of --major, --minor, or --patch may be specified"
        exit 1
      fi
      KIND="${1#--}"
      shift
      ;;
    --help|-h)
      usage
      ;;
    *)
      break
      ;;
  esac
done

# Remaining args form the name
if [[ -z "${KIND}" || $# -lt 1 ]]; then
  usage
fi

NAME="$*"
NAME="${NAME// /_}"

# Count existing changelog files (any files in directory)
INDEX=$(find . -maxdepth 1 -type f \( -name '*.md' -o -name '*.markdown' \) | wc -l | tr -d ' ')

FILENAME="${INDEX}-${KIND}-${NAME}.md"

if [[ -e "$FILENAME" ]]; then
  echo "Error: $FILENAME already exists"
  exit 1
fi

cat > "$FILENAME" <<EOF
# ${NAME//_/ }

## Type
${KIND}

EOF

$EDITOR $FILENAME

echo "Created changelog entry: $FILENAME"
