import os
import argparse

def output_file_content(file, temp):
    temp.write(f"<<< FILE START: {file} >>>\n")
    with open(file, 'r') as f:
        temp.write(f.read())
    temp.write(f"<<< FILE END: {file} >>>\n\n")  # Add a blank line after each file

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
           '4. python ShowFilesHere.py py txt --only pipelines/generator.py models\n'
           '   Lists files with .py and .txt extensions only for "generator.py" in the "pipelines" directory and files in the "models" directory\n\n'
           '5. python ShowFilesHere.py tex pdf --ignore feedback --head 20\n'
           '   Lists files with .tex and .pdf extensions, ignores those in the feedback folder, and shows the first 20 lines of the output\n\n'
           'To make a file with the entire output called show.txt, run:\n'
           '   python ShowFilesHere.py tex pdf --ignore feedback --head 20 > show.txt\n',
    formatter_class=argparse.RawTextHelpFormatter
)
parser.add_argument('--ignore', nargs='*', default=[], help='Directories to ignore')
parser.add_argument('--only', nargs='*', default=[], help='Specific files or directories to include')
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
    if args.only:
        temp.write(f"Index of files from --only paths: {', '.join(args.only)}\n")
        for only_path in args.only:
            if os.path.isfile(only_path):
                if any(only_path.endswith(f".{ext}") for ext in args.extensions):
                    temp.write(only_path + '\n')
                    output_file_content(only_path, temp)
            elif os.path.isdir(only_path):
                for root, _, files in os.walk(only_path):
                    for file in files:
                        if any(file.endswith(f".{ext}") for ext in args.extensions):
                            file_path = os.path.join(root, file)
                            temp.write(file_path + '\n')
                            output_file_content(file_path, temp)
            else:
                temp.write(f"Warning: Path not found - {only_path}\n")
    else:
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
                    output_file_content(os.path.join(root, file), temp)

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
