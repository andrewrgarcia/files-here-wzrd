#!/usr/bin/env python3

import os
import sys
import re

# Check if input file is provided
if len(sys.argv) < 2:
    print("Usage: python MakeFilesHere.py <input_file.txt>")
    sys.exit(1)

input_file = sys.argv[1]
current_file = ""
file_content = []
in_file_content = False

# Regular expressions for detecting file start and end markers
start_pattern = re.compile(r"^<<< FILE START: (.+) >>>$")
end_pattern = re.compile(r"^<<< FILE END: (.+) >>>$")

try:
    # Read the input file and process lines
    with open(input_file, 'r') as f:
        for line in f:
            line = line.rstrip()

            # Detect the start of a file section
            start_match = start_pattern.match(line)
            if start_match:
                # Save the previous file if any
                if current_file:
                    os.makedirs(os.path.dirname(current_file), exist_ok=True)
                    with open(current_file, 'w') as outfile:
                        outfile.write(''.join(file_content))

                # Start a new file, capturing the file path
                current_file = start_match.group(1)
                file_content = []
                in_file_content = True
                continue

            # Detect the end of a file section
            end_match = end_pattern.match(line)
            if end_match:
                # Ensure end marker matches start marker path
                if current_file == end_match.group(1):
                    os.makedirs(os.path.dirname(current_file), exist_ok=True)
                    with open(current_file, 'w') as outfile:
                        outfile.write(''.join(file_content))
                    # Reset for the next file
                    current_file = ""
                    file_content = []
                    in_file_content = False
                else:
                    print(f"Warning: End marker file path does not match start marker for {current_file}")
                    sys.exit(1)
                continue

            # Accumulate file content if in file content section
            if in_file_content:
                file_content.append(line + "\n")

    # Save the last file content if any
    if current_file:
        os.makedirs(os.path.dirname(current_file), exist_ok=True)
        with open(current_file, 'w') as outfile:
            outfile.write(''.join(file_content))

    print(f"File structure recreated from {input_file}.")
except FileNotFoundError:
    print(f"Error: File {input_file} not found.")
    sys.exit(1)

