# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

mkdir -p "$1"

cat <<EOF > "$1/file"

EOF

