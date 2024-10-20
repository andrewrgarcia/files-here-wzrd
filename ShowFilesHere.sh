#!/bin/bash

# Function to output the content of a file
output_file_content() {
    local file="$1"
    echo "===== Content of $file ====="
    cat "$file"
    echo "============================"
}

# Default directories to ignore
ignore_dirs=("venv" "build" "__pycache__")

# Display help section if --help is passed
if [[ "$1" == "--help" ]]; then
    cat << EOF
Usage: ./ShowFilesHere.sh [extensions] [--ignore DIR1 DIR2 ...] [--head N] [--tail N]

List files with specified extensions and display their content.

Examples:
1. ./ShowFilesHere.sh
   Lists all PYTHON files set by default and displays their content

2. ./ShowFilesHere.sh js html css
   Lists all files with .js, .html, and .css extensions only

3. ./ShowFilesHere.sh tsx js html --ignore node_modules
   Lists all files with .tsx, .js, and .html extensions and ignores those in the node_modules folder

4. ./ShowFilesHere.sh py txt --ignore logs temp --tail 5
   Lists files with .py and .txt extensions and shows the last 5 lines of the output

5. ./ShowFilesHere.sh tex pdf --ignore feedback --head 20
   Lists files with .tex and .pdf extensions, ignores those in the feedback folder, and shows the first 20 lines of the output

To make a file with the entire output called show.txt, run:
   ./ShowFilesHere.sh tex pdf --ignore feedback --head 20 > show.txt
EOF
    exit 0
fi

# Initialize variables
extensions=()
additional_ignore_dirs=()
head_count=0
tail_count=0

# Argument parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --ignore)
            shift
            while [[ $# -gt 0 && $1 != --* ]]; do
                additional_ignore_dirs+=("$1")
                shift
            done
            ;;
        --head)
            shift
            head_count="$1"
            shift
            ;;
        --tail)
            shift
            tail_count="$1"
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            extensions+=("$1")
            shift
            ;;
    esac
done

# Merge default and additional ignore directories
ignore_dirs+=("${additional_ignore_dirs[@]}")

# Convert ignore directories to find -path arguments
ignore_find_args=()
for dir in "${ignore_dirs[@]}"; do
    ignore_find_args+=(-path "./$dir" -prune -o)
done

# Set default extension if none provided
if [ ${#extensions[@]} -eq 0 ]; then
    extensions=("py")
fi

# Create a temporary file to hold the output
temp_file=$(mktemp)

# Collect file paths and content
{
    echo "Index of files with the extensions: ${extensions[*]} (excluding ${ignore_dirs[*]}):"
    for ext in "${extensions[@]}"; do
        find . "${ignore_find_args[@]}" -type f -name "*.$ext" -print
    done

    echo "==============================================="
    echo

    # Export the function to use with find
    export -f output_file_content

    for ext in "${extensions[@]}"; do
        find . "${ignore_find_args[@]}" -type f -name "*.$ext" -exec bash -c 'output_file_content "$0"' {} \;
    done
} > "$temp_file"

# Apply head or tail if specified
if (( head_count > 0 )); then
    head -n "$head_count" "$temp_file"
elif (( tail_count > 0 )); then
    tail -n "$tail_count" "$temp_file"
else
    cat "$temp_file"
fi

# Clean up
rm "$temp_file"
