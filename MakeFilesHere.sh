#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: ./MakeFilesHere.sh <input_file.txt>"
    exit 1
fi

input_file="$1"
current_file=""
file_content=""
in_file_content=false

# Regular expressions for detecting file start and end markers
start_pattern="^<<< FILE START: (.+) >>>$"
end_pattern="^<<< FILE END: (.+) >>>$"

# Create the files and directories based on the parsed structure
while IFS= read -r line || [[ -n "$line" ]]; do
    # Detect the start of a file section
    if [[ "$line" =~ $start_pattern ]]; then
        # Save the previous file if any
        if [ -n "$current_file" ]; then
            mkdir -p "$(dirname "$current_file")"
            echo "$file_content" > "$current_file"
        fi

        # Start a new file, capturing the file path
        current_file="${BASH_REMATCH[1]}"
        file_content=""
        in_file_content=true
    elif [[ "$line" =~ $end_pattern ]]; then
        # End of file content section; only proceed if path matches
        if [ "$current_file" == "${BASH_REMATCH[1]}" ]; then
            mkdir -p "$(dirname "$current_file")"
            echo "$file_content" > "$current_file"
            current_file=""
            file_content=""
            in_file_content=false
        else
            echo "Warning: End marker file path does not match start marker for $current_file"
            exit 1
        fi
    elif $in_file_content; then
        # Accumulate file content
        file_content+="$line"$'\n'
    fi
done < "$input_file"

# Save the last file content if any
if [ -n "$current_file" ]; then
    mkdir -p "$(dirname "$current_file")"
    echo "$file_content" > "$current_file"
fi

echo "File structure recreated from $input_file."
