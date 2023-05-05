#!/bin/bash

# Check if Zenity is installed
if ! command -v zenity &> /dev/null; then
  echo "Zenity is not installed. Please install Zenity and try again."
  exit 1
fi

# Ask for the module name
module_name=$(zenity --entry --title "Module Name" --text "Enter the module name:")

# Choose directory using file explorer
target_dir=$(zenity --file-selection --title "Choose target directory" --directory)

if [ ! -d "$target_dir" ]; then
  zenity --error --text "The directory does not exist. Please check the path and try again."
  exit 1
fi

# Create the module directory
mkdir -p "$target_dir/$module_name/components"
mkdir -p "$target_dir/$module_name/all_functions"
touch "$target_dir/$module_name/__init__.py"

# Initialize additional directory imports list
additional_directory_imports=""

# Ask the user if they want to add additional directory imports
response=$(zenity --question --text="Do you want to add additional directory imports?" --width=300 --height=100; echo $?)
if [ $response -eq 0 ]; then
  while true; do
    additional_import=$(zenity --file-selection --title "Select an additional directory to import" --directory)

    if [ -z "$additional_import" ]; then
      break
    fi

    additional_directory_imports+="$additional_import,"

    response=$(zenity --question --text="Do you want to add another directory import?" --width=300 --height=100; echo $?)
    if [ $response -eq 1 ]; then
      break
    fi
  done
fi
# Create the main Python file
module_file_path="$target_dir/$module_name/$module_name.py"

cat > "$module_file_path" << EOL
import os
import sys
import json
import importlib
import importlib.util
from collections import defaultdict

# Function to import all modules from a directory
def import_all_from_folder(folder_path):
    modules = []
    functions = defaultdict(list)

    # Append the folder_path and all its subdirectories to sys.path
    for root, dirs, files in os.walk(folder_path):
        sys.path.append(root)

    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith('.py'):
                module_name = file[:-3]
                module_path = os.path.relpath(root, folder_path).replace(os.sep, ".")
                if module_path:
                    module_name = f"{module_path}.{module_name}"
                
                spec = importlib.util.spec_from_file_location(module_name, os.path.join(root, file))
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)

                modules.append(module_name)

                for attr_name in dir(module):
                    attr = getattr(module, attr_name)
                    if callable(attr) and not attr_name.startswith('_'):
                        functions[module_name].append(attr_name)
                        # Add the function directly to the current module's globals
                        globals()[attr_name] = attr
    return modules, functions
# Import all components
components_dir = os.path.join(os.path.dirname(__file__), "components")
modules, functions = import_all_from_folder(components_dir)

# Import additional directories
additional_directory_imports = "${additional_directory_imports::-1}"
if additional_directory_imports:
    additional_directories = additional_directory_imports.split(",")
    for additional_directory in additional_directories:
        additional_modules, additional_functions = import_all_from_folder(additional_directory)
        modules.extend(additional_modules)
        for key, value in additional_functions.items():
            functions[key].extend(value)

# Save function lists
all_functions_path = os.path.join(os.path.dirname(__file__), "all_functions")
with open(os.path.join(all_functions_path, "all_modules.json"), "w") as f:
    json.dump(modules, f)

with open(os.path.join(all_functions_path, "all_functions.json"), "w") as f:
    json.dump(functions, f)

# Find duplicate functions
duplicates = defaultdict(list)
for module, func_list in functions.items():
    for func in func_list:
        for other_module, other_func_list in functions.items():
            if module != other_module and func in other_func_list:
                duplicates[func].append((module, other_module))

# Save duplicates to JSON
with open(os.path.join(all_functions_path, "all_function_duplicates.json"), "w") as f:
    json.dump(duplicates, f)

EOL

# Create setup.py file
setup_file_path="$target_dir/$module_name/setup.py"

cat > "$setup_file_path" << EOL
from setuptools import setup, find_packages

setup(
    name='$module_name',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[
        # Add your module dependencies here
    ],
    entry_points={
        'console_scripts': [
            '$module_name = $module_name.main_module:main',
        ],
    },
)

EOL


# Change to the module directory and run setup.py
cd "$target_dir/$module_name"
python3 setup.py develop --user
