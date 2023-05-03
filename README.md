# Python Module Creator

This bash script is designed to create a Python module with a pre-defined directory structure and necessary files for development. It prompts the user to enter the module name and target directory. Then it creates the file directory structure and necessary files in the target directory.

The script checks if Zenity is installed or not. If it is not installed, then it asks the user to install Zenity and try again.

The file directory structure that this script creates is as follows:

```
module_name/
    components/
        __init__.py
        functions.py
        utils/
            __init__.py
            cmd/
                cmd.py
            class_calls.py
            path_utils/
                __init__.py
                mapping_dirs.py
                path_map.py
    class/
    __init__.py
    path_map.py
    read_me/
        __init__.txt
        custom_utils.txt
    $module_name.py
    setup.py
    custom_utils.py
    $module_name.egg-info/
        PKG-INFO
        SOURCES.txt
        dependency_links.txt
        top_level.txt
        requires.txt
    __pycache__/
        custom_utils.cpython-310.pyc
        $module_name.cpython-310.pyc
        __init__.cpython-310.pyc
    path_map.py
```

The script prompts the user to select the library directories for the `path_libraries` dictionary. The script uses the Zenity file selection dialog to select the library directories. The `path_libraries` dictionary maps the library name to its directory path.

After creating the file directory structure, the script prompts the user to select the Python files for importing libraries in each directory. It then generates import statements and writes them to the main Python file.

The script then creates an `__init__.py` file for each library directory and writes import statements to it.

Finally, the script generates the `setup.py` file with extracted dependencies.

## Requirements

This script requires Zenity to be installed on the system.

## Usage

To use this script, run the following command:

```bash
bash create_python_module.sh
```

This will launch the script, which will prompt the user to enter the module name and target directory. The script will then create the file directory structure and necessary files in the target directory.

## Acknowledgments

This script was inspired by [Python Boilerplate](https://github.com/cookiecutter/cookiecutter-pypackage), a project template for Python packages.
