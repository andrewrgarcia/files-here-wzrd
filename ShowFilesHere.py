import os
import argparse

def output_file_content(file):
    print(f"===== Content of {file} =====")
    with open(file, 'r') as f:
        print(f.read())
    print("============================")

# Default directories to ignore
ignore_dirs = ["venv", "build", "__pycache__"]

# Parse arguments
parser = argparse.ArgumentParser(description='List files and display content')
parser.add_argument('--ignore', nargs='*', default=[], help='Directories to ignore')
parser.add_argument('--head', type=int, default=0, help='Number of lines to show from the start')
parser.add_argument('--tail', type=int, default=0, help='Number of lines to show from the end')
parser.add_argument('extensions', nargs='*', default=['py'], help='File extensions to include')

args = parser.parse_args()

# Merge default ignore directories with additional ones
ignore_dirs.extend(args.ignore)

# Convert ignore directories to find -path arguments for Windows
ignore_find_args = []
for dir in ignore_dirs:
    ignore_find_args.append(os.path.join('.', dir))

# Set default extension if none provided
if not args.extensions:
    args.extensions = ["py"]

# Create a temporary file to hold the output
temp_file = "temp_output.txt"

# Print the directory structure index of all files with the given extensions
with open(temp_file, 'w') as temp:
    temp.write(f"Index of files with the extensions: {', '.join(args.extensions)} in the directory structure (excluding {', '.join(ignore_dirs)}):\n")
    for root, dirs, files in os.walk('.'):
        # Skip ignored directories
        dirs[:] = [d for d in dirs if os.path.join(root, d) not in ignore_find_args]
        for file in files:
            if any(file.endswith(f".{ext}") for ext in args.extensions):
                temp.write(os.path.join(root, file) + '\n')

    # Add a separator between the index and the file contents
    temp.write("===============================================\n\n")

    # Find all files with the given extensions recursively and output their content with headers
    for root, dirs, files in os.walk('.'):
        # Skip ignored directories
        dirs[:] = [d for d in dirs if os.path.join(root, d) not in ignore_find_args]
        for file in files:
            if any(file.endswith(f".{ext}") for ext in args.extensions):
                temp.write(f"===== Content of {os.path.join(root, file)} =====\n")
                with open(os.path.join(root, file), 'r') as f:
                    temp.write(f.read())
                temp.write("============================\n")

# Apply head or tail to the full output if specified
if args.head > 0:
    with open(temp_file, 'r') as temp:
        print(''.join(temp.readlines()[:args.head]))
elif args.tail > 0:
    with open(temp_file, 'r') as temp:
        print(''.join(temp.readlines()[-args.tail:]))
else:
    with open(temp_file, 'r') as temp:
        print(temp.read())

# Remove the temporary file
os.remove(temp_file)
