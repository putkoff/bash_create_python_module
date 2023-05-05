# Python Module Creation Script

This bash script automates the process of creating a Python module, including the module structure and necessary files. The script allows the user to define the module name, target directory, and additional directory imports using Zenity dialogs. 

## Requirements

- Zenity (for dialog prompts)
- Python 3

## Usage

1. Ensure Zenity is installed on your system. If not, install it using the package manager for your distribution. For example, on Ubuntu, you can use `sudo apt-get install zenity`.

2. Save the provided bash script to a file, e.g., `create_module.sh`.

3. Make the script executable by running `chmod +x create_module.sh`.

4. Run the script using `./create_module.sh`. Follow the prompts to define the module name, target directory, and additional directory imports (if any).

## What the script does

1. Checks if Zenity is installed. If not, it displays an error message and exits.

2. Asks the user for the module name using a Zenity dialog.

3. Prompts the user to choose the target directory for the module using a Zenity file selection dialog.

4. Creates the module structure, including the main module file, `__init__.py`, `components` directory, and `all_functions` directory.

5. Asks the user if they want to add additional directory imports. If yes, it prompts the user to select the directories using Zenity file selection dialogs.

6. Generates the main module file (`<module_name>.py`), which includes a function to import all modules from a folder, import components, import additional directories (if specified), save function lists, and find duplicate functions.

7. Generates a `setup.py` file for the module, including the package name, version, and entry points.

8. Changes to the module directory and runs `python3 setup.py develop --user` to install the module in development mode.

## Output

The script creates a Python module with the following structure:

```
<target_dir>/
  <module_name>/
    __init__.py
    <module_name>.py
    setup.py
    components/
    all_functions/
      all_modules.json
      all_functions.json
      all_function_duplicates.json
```

The generated module can be imported and used in other Python projects.
```
