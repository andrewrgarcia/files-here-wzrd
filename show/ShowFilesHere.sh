#!/bin/bash

# Function to output the content of a file with <<< >>> format and a space after each file
output_file_content() {
    local file="$1"
    echo "<<< FILE START: $file >>>"
    cat "$file"
    echo "<<< FILE END: $file >>>"
    echo  # Add a blank line after each file
}

# Default directories to ignore
ignore_dirs=("venv" "build" "__pycache__")
only_paths=()

# Display help section if --help is passed
if [[ "$1" == "--help" ]]; then
    cat << EOF
Usage: ./ShowFilesHere.sh [extensions] [--ignore DIR1 DIR2 ...] [--only PATH1 PATH2 ...] [--head N] [--tail N]

List files with specified extensions and display their content.

Examples:
1. ./ShowFilesHere.sh
   Lists all PYTHON files set by default and displays their content

2. ./ShowFilesHere.sh js html css
   Lists all files with .js, .html, and .css extensions only

3. ./ShowFilesHere.sh tsx js html --ignore node_modules
   Lists all files with .tsx, .js, and .html extensions and ignores those in the node_modules folder

4. ./ShowFilesHere.sh py txt --only pipelines/generator.py models
   Lists files with .py and .txt extensions only for "generator.py" in the "pipelines" directory and files in the "models" directory

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
        --only)
            shift
            while [[ $# -gt 0 && $1 != --* ]]; do
                only_paths+=("$1")
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
    if [ ${#only_paths[@]} -eq 0 ]; then
        # Standard logic if no --only flag is provided
        echo "Index of files with the extensions: ${extensions[*]} (excluding ${ignore_dirs[*]}):"
        for ext in "${extensions[@]}"; do
            find . "${ignore_find_args[@]}" -type f -name "*.$ext" -print
        done
    else
        # Logic for --only flag
        echo "Index of files from --only paths: ${only_paths[*]}"
        for path in "${only_paths[@]}"; do
            if [[ -d "$path" ]]; then
                # If it's a directory, find matching files within it
                for ext in "${extensions[@]}"; do
                    find "$path" -type f -name "*.$ext" -print
                done
            elif [[ -f "$path" ]]; then
                # If it's a specific file, check if it matches the extensions
                for ext in "${extensions[@]}"; do
                    [[ "$path" == *.$ext ]] && echo "$path"
                done
            else
                echo "Warning: Path not found - $path" >&2
            fi
        done
    fi

    echo "==============================================="
    echo

    # Export the function to use with find
    export -f output_file_content

    if [ ${#only_paths[@]} -eq 0 ]; then
        for ext in "${extensions[@]}"; do
            find . "${ignore_find_args[@]}" -type f -name "*.$ext" -exec bash -c 'output_file_content "$0"' {} \;
        done
    else
        for path in "${only_paths[@]}"; do
            if [[ -d "$path" ]]; then
                for ext in "${extensions[@]}"; do
                    find "$path" -type f -name "*.$ext" -exec bash -c 'output_file_content "$0"' {} \;
                done
            elif [[ -f "$path" ]]; then
                for ext in "${extensions[@]}"; do
                    [[ "$path" == *.$ext ]] && output_file_content "$path"
                done
            fi
        done
    fi
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
