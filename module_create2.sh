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

# Create the file directory structure
mkdir -p "$target_dir/$module_name/components/utils/__pycache__"
mkdir -p "$target_dir/$module_name/components/utils/path_utils"
mkdir -p "$target_dir/$module_name/components/utils/cmd"
mkdir -p "$target_dir/$module_name/components/class"
mkdir -p "$target_dir/$module_name/$module_name.egg-info"
mkdir -p "$target_dir/$module_name/__pycache__"
mkdir -p "$target_dir/$module_name/read_me"

# Create the files
touch "$target_dir/path_map.py"
touch "$target_dir/$module_name/components/functions.py"
touch "$target_dir/$module_name/components/utils/__pycache__/class_calls.cpython-310.pyc"
touch "$target_dir/$module_name/components/utils/__init__.py"
touch "$target_dir/$module_name/components/utils/path_utils/mapping_dirs.py"
touch "$target_dir/$module_name/components/utils/path_utils/path_map.py"
touch "$target_dir/$module_name/components/utils/cmd/cmd.py"
touch "$target_dir/$module_name/components/utils/class_calls.py"
touch "$target_dir/$module_name/$module_name.egg-info/PKG-INFO"
touch "$target_dir/$module_name/$module_name.egg-info/SOURCES.txt"
touch "$target_dir/$module_name/$module_name.egg-info/dependency_links.txt"
touch "$target_dir/$module_name/$module_name.egg-info/top_level.txt"
touch "$target_dir/$module_name/$module_name.egg-info/requires.txt"
touch "$target_dir/$module_name/__pycache__/custom_utils.cpython-310.pyc"
touch "$target_dir/$module_name/__pycache__/$module_name.cpython-310.pyc"
touch "$target_dir/$module_name/__pycache__/__init__.cpython-310.pyc"
touch "$target_dir/$module_name/__init__.py"
touch "$target_dir/$module_name/read_me/__init__.txt"
touch "$target_dir/$module_name/read_me/custom_utils.txt"
touch "$target_dir/$module_name/$module_name.py"
touch "$target_dir/$module_name/path_map.py"
touch "$target_dir/$module_name/setup.py"
touch "$target_dir/$module_name/custom_utils.py"

zenity --info --text "File directory created successfully in: $target_dir"

# Select library directories for the path_libraries dictionary
finished=false
path_libraries=""
while [ "$finished" = false ]; do
  library_dir=$(zenity --file-selection --title "path_libraries dictionary: Select a library directory" --directory)
  library_name=$(basename "$library_dir")
  path_libraries+="\"$library_name\":\"$library_dir\","
  response=$(zenity --question --text="Do you want to add another library directory?" --width=300 --height=100; echo $?)
  if [ $response -eq 1 ]; then
    finished=true
  fi
done

path_libraries="{${path_libraries::-1}}"

# Convert path_libraries JSON string to an associative array
declare -A path_libraries_array
path_libraries_array=$(echo "import json; d = json.loads('$path_libraries'); print({k: v for k, v in d.items()})" | python3)

library_files=""
for library_name in "${!path_libraries_array[@]}"; do
  library_dir="${path_libraries_array[$library_name]}"
  # Select Python files for importing libraries in each directory
  selected_files=$(zenity --file-selection --title "Select Python files for importing libraries in $library_name" --file-filter="*.py" --multiple --separator="|" --filename="$library_dir/")
  if [ -n "$selected_files" ]; then
    library_files+="$selected_files|"
  fi
done
library_files=${library_files::-1}  # Remove the trailing "|"

# Create the main Python file
module_file_path="$target_dir/$module_name/$module_name.py"
super_setup_path="$target_dir/$module_name/setup.py"
super_init_path="$target_dir/$module_name/__init__.py"
# Write the content to the file
cat > "$module_file_path" << EOL
import os
import sys
import json
from pathlib import Path
import custom_utils
from custom_utils import *
from components.functions import *
# Create a function from a string
def mk_libraries(path_libraries):
    path_keys = list(path_libraries.keys())
    for k in range(0,len(path_keys)):
        key = path_keys[k]
        change_glob_GPT(key,Path(path_libraries[key]))
        if str(get_globes(key)) not in sys.path:
            sys.path.append(str(get_globes(key)))
path_libraries=$path_libraries
mk_libraries(path_libraries)
EOL

# Generate import statements and init file contents for each directory
declare -A init_file_contents
continue_adding_imports=true
while $continue_adding_imports; do
  IFS="|" read -ra library_paths <<< "$library_files"
  import_statements=""
  for path in "${library_paths[@]}"; do
    dirname=$(dirname "$path")
    filename=$(basename "$path")
    module_name="${filename%.*}"
    import_statements+="from $module_name import *\n"
    init_file_contents["$dirname"]+="from .$module_name import *\n"
  done

  # Append import statements to the main Python file
  echo -e "$import_statements" >> "$module_file_path"

  # Ask the user if they want to continue adding imports
  response=$(zenity --question --text="Do you want to add more imports?" --width=300 --height=100; echo $?)
  if [ $response -eq 1 ]; then
    continue_adding_imports=false
  else
    # Iterate through path_libraries to select Python files for importing libraries
    for library_name in "${!path_libraries_array[@]}"; do
      library_dir="${path_libraries_array[$library_name]}"

      # Select Python files for importing libraries in each directory
      selected_files=$(zenity --file-selection --title "Select Python files for importing libraries in $library_name" --file-filter="*.py" --multiple --separator="|" --filename="$library_dir/")
      if [ -n "$selected_files" ]; then
        library_files+="$selected_files|"
      fi
    done
    library_files=${library_files::-1}  # Remove the trailing "|"
  fi
done



# Write the contents of __init__ files
for dir in "${!init_file_contents[@]}"; do
  echo -e "${init_file_contents[$dir]}" > "$super_init_path"
done

# Generate setup.py with extracted dependencies

IFS="|" read -ra library_paths <<< "$library_files"
dependencies=""
for path in "${library_paths[@]}"; do
  file_dependencies=$(grep -E '^import |^from ' "$path" | sort -u | awk '{print $2}' | grep -vE 'os|sys|json|pathlib|re|time|datetime|custom_utils|components.functions' | sed 's/,//g' | tr '\n' ',')
  dependencies+="$file_dependencies,"
done

# Remove duplicate dependencies and trailing comma
IFS="," read -ra unique_dependencies <<< "$(echo "$dependencies" | tr ',' '\n' | sort -u | tr '\n' ',')"
dependencies=""
for dep in "${unique_dependencies[@]}"; do
  if [ -n "$dep" ]; then
    dependencies+="$dep,"
  fi
done
dependencies=${dependencies%,}

cat > "$super_setup_path" << EOL
from setuptools import setup, find_packages

setup(
    name="$module_name",
    version="0.1",
    packages=find_packages(),
    install_requires=[
        $dependencies
    ],
)
EOL

zenity --info --text "Python module created successfully in: $target_dir"

