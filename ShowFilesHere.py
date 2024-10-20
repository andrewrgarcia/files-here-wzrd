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
parser = argparse.ArgumentParser(
    description='List files with specified extensions and display their content',
    epilog='Examples:\n'
           '1. python ShowFilesHere.py\n'
           '   Lists all PYTHON files set by default and displays their content\n\n'
           '2. python ShowFilesHere.py js html css\n'
           '   Lists all files with .js, .html, and .css extensions only\n\n'
           '3. python ShowFilesHere.py tsx js html --ignore node_modules\n'
           '   Lists all files with .tsx, .js, and .html extensions and ignores those in the node_modules folder\n\n'
           '4. python ShowFilesHere.py py txt --ignore logs temp --tail=5\n'
           '   Lists files with .py and .txt extensions and shows the last 5 lines of the output\n\n'
           '5. python ShowFilesHere.py tex pdf --ignore feedback --head 20\n'
           '   Lists files with .tex and .pdf extensions, ignores those in the feedback folder, and shows the first 20 lines of the output\n\n'
           'To make a file with the entire output called show.txt, run:\n'
           '   python ShowFilesHere.py tex pdf --ignore feedback --head 20 > show.txt\n',
    formatter_class=argparse.RawTextHelpFormatter
)
parser.add_argument('--ignore', nargs='*', default=[], help='Directories to ignore')
parser.add_argument('--head', type=int, default=0, help='Number of lines to show from the start of the output')
parser.add_argument('--tail', type=int, default=0, help='Number of lines to show from the end of the output')
parser.add_argument('extensions', nargs='*', default=['py'], help='File extensions to include (default: py)')

args = parser.parse_args()

# Merge default ignore directories with additional ones
ignore_dirs.extend(args.ignore)

# Create ignore path list for filtering directories
ignore_find_args = [os.path.join('.', dir) for dir in ignore_dirs]

# Create a temporary file to hold the output
temp_file = "temp_output.txt"

# Collect files and output their paths and content
with open(temp_file, 'w') as temp:
    temp.write(f"Index of files with extensions: {', '.join(args.extensions)} (excluding: {', '.join(ignore_dirs)})\n")
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if os.path.join(root, d) not in ignore_find_args]
        for file in files:
            if any(file.endswith(f".{ext}") for ext in args.extensions):
                temp.write(os.path.join(root, file) + '\n')
    
    temp.write("\n===============================================\n\n")
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if os.path.join(root, d) not in ignore_find_args]
        for file in files:
            if any(file.endswith(f".{ext}") for ext in args.extensions):
                temp.write(f"===== Content of {os.path.join(root, file)} =====\n")
                with open(os.path.join(root, file), 'r') as f:
                    temp.write(f.read())
                temp.write("============================\n")

# Output content with head or tail option
with open(temp_file, 'r') as temp:
    lines = temp.readlines()
    if args.head > 0:
        print(''.join(lines[:args.head]))
    elif args.tail > 0:
        print(''.join(lines[-args.tail:]))
    else:
        print(''.join(lines))

# Remove the temporary file
os.remove(temp_file)
