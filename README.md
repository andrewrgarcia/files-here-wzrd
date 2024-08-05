# ShowFilesHere.sh

## Overview
`ShowFilesHere.sh` is a versatile bash script designed to list and display the content of files with specified extensions within the current directory and its subdirectories. By default, it ignores certain directories to keep your search focused and efficient. This tool is useful for developers, researchers, and students to quickly understand and navigate large codebases or datasets.

## Example Usage

### Linux and macOS
1. **Ensure the script is executable**:
    ```sh
    chmod +x ShowFilesHere.sh
    ```

2. **Run the script**:
    ```sh
    ./ShowFilesHere.sh py txt --ignore logs/ temp/ > output_files_here.txt
    ```

### Windows (Using Git Bash or WSL)

#### Git Bash
1. **Download and install Git for Windows** from [git-scm.com](https://git-scm.com/).
2. **Open Git Bash** and navigate to the directory containing `ShowFilesHere.sh`.
3. **Ensure the script is executable**:
    ```sh
    chmod +x ShowFilesHere.sh
    ```

4. **Run the script**:
    ```sh
    ./ShowFilesHere.sh py txt --ignore logs/ temp/ > output_files_here.txt
    ```

#### Windows Subsystem for Linux (WSL)
1. **Install WSL** (if not already installed):
    ```sh
    wsl --install
    ```

2. **Open WSL** and navigate to the directory containing `ShowFilesHere.sh`.
3. **Ensure the script is executable**:
    ```sh
    chmod +x ShowFilesHere.sh
    ```

4. **Run the script**:
    ```sh
    ./ShowFilesHere.sh py txt --ignore logs/ temp/ > output_files_here.txt
    ```

### Using the Output
Use the generated `output_files_here.txt` for further analysis with AI tools like ChatGPT or Gemini. For instance, you can ask:
- "Find the main function in the repo with these files."
- "What does the `process_data` function do in the given files?"
- "Identify the classes defined in the following files and their methods."


## License
This script is open-source and available under the [MIT License](LICENSE).
