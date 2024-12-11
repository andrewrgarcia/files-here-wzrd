#!/bin/bash

# Script: ShowPDFsHere
# Description: Recursively lists all PDF files in a directory and its subdirectories,
#              displaying their content in indexed form with advanced options.
# Dependencies: pdftotext (install with `sudo apt install poppler-utils`)

# Function to check if pdftotext is installed
check_dependencies() {
    if ! command -v pdftotext &> /dev/null; then
        echo "Error: pdftotext is not installed. Please install it with 'sudo apt install poppler-utils'."
        exit 1
    fi
}

if [[ "$1" == "--help" ]]; then
    cat << EOF
Usage: ./ShowPDFsHere.sh [--ignore DIR1 DIR2 ...] [--only PATH1 PATH2 ...] [--head N] [--tail N]

List PDF files and display their content with options for filtering and previewing.

Examples:
1. ./ShowPDFsHere.sh
   Lists all PDF files in the current directory and subdirectories and displays their content.

2. ./ShowPDFsHere.sh --ignore temp logs
   Lists all PDF files but ignores those in the "temp" and "logs" directories.

3. ./ShowPDFsHere.sh --only /home/user/docs /home/user/example.pdf
   Lists only PDF files in "/home/user/docs" and the specific file "/home/user/example.pdf".

4. ./ShowPDFsHere.sh --head 20
   Lists all PDF files and shows the first 20 lines of their content.

5. ./ShowPDFsHere.sh --tail 15
   Lists all PDF files and shows the last 15 lines of their content.

6. ./ShowPDFsHere.sh --ignore logs temp --only /home/user/docs --head 10
   Lists PDF files in "/home/user/docs", ignoring "logs" and "temp" directories, and shows the first 10 lines of their content.

To save the output to a file, use:
   ./ShowPDFsHere.sh --ignore logs --head 20 > output.txt
EOF
    exit 0
fi

# Function to display PDF content
display_pdf_content() {
    local pdf="$1"
    local head_lines="$2"
    local tail_lines="$3"
    if [ "$head_lines" -gt 0 ]; then
        pdftotext "$pdf" - 2>/dev/null | head -n "$head_lines"
    elif [ "$tail_lines" -gt 0 ]; then
        pdftotext "$pdf" - 2>/dev/null | tail -n "$tail_lines"
    else
        pdftotext "$pdf" - 2>/dev/null | head -n 50
    fi
}

# Main function
show_pdfs() {
    local ignore_dirs=()
    local only_paths=()
    local head_lines=0
    local tail_lines=0

    # Parse arguments
    while [[ "$1" != "" ]]; do
        case "$1" in
            --ignore)
                shift
                while [[ "$1" != "" && "$1" != "--" && "$1" != "--only" && "$1" != "--head" && "$1" != "--tail" ]]; do
                    ignore_dirs+=("$1")
                    shift
                done
                ;;
            --only)
                shift
                while [[ "$1" != "" && "$1" != "--" && "$1" != "--ignore" && "$1" != "--head" && "$1" != "--tail" ]]; do
                    only_paths+=("$1")
                    shift
                done
                ;;
            --head)
                shift
                head_lines="$1"
                shift
                ;;
            --tail)
                shift
                tail_lines="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    local pdf_files=()

    if [ "${#only_paths[@]}" -gt 0 ]; then
        # Restrict search to specified paths
        for path in "${only_paths[@]}"; do
            if [ -d "$path" ]; then
                mapfile -t temp_files < <(find "$path" -type f -name "*.pdf" 2>/dev/null)
                pdf_files+=("${temp_files[@]}")
            elif [[ "$path" == *.pdf ]]; then
                pdf_files+=("$path")
            fi
        done
    else
        # Search in the current directory and subdirectories
        mapfile -t pdf_files < <(find . -type f -name "*.pdf" 2>/dev/null)
    fi

    # Exclude ignored directories
    if [ "${#ignore_dirs[@]}" -gt 0 ]; then
        for ignore in "${ignore_dirs[@]}"; do
            pdf_files=("${pdf_files[@]//*$ignore*}")
        done
    fi

    # Check if there are any PDFs to process
    if [ ${#pdf_files[@]} -eq 0 ]; then
        echo "No PDF files found with the specified filters."
        exit 0
    fi

    # Print the index of files
    echo "Index of files with the extension: pdf"
    echo "(excluding directories: ${ignore_dirs[*]})"
    local index=1
    for pdf in "${pdf_files[@]}"; do
        echo "[$index] $pdf"
        index=$((index + 1))
    done
    echo "==============================================="

    # Print content of each file
    index=1
    for pdf in "${pdf_files[@]}"; do
        echo "<<< FILE START: [$index] $pdf >>>"
        display_pdf_content "$pdf" "$head_lines" "$tail_lines"
        echo "<<< FILE END: [$index] $pdf >>>"
        echo
        index=$((index + 1))
    done
}

# Check dependencies
check_dependencies

# Run the main function
show_pdfs "$@"
