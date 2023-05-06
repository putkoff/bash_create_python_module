#!/bin/bash

# Function to get a value from .env file or ask user if not present
get_value() {
    key=$1
    prompt=$2
    value=$(grep "^$key=" .env | cut -d '=' -f2)
    if [ -z "$value" ]; then
        echo "$prompt"
        read value
    fi
    echo $value
}

echo "Installing required tools..."
pip install setuptools wheel twine

if [ -f .env ]; then
    echo "Reading values from .env file..."
    package_name=$(get_value "PACKAGE_NAME" "Enter your package name:")
    package_description=$(get_value "PACKAGE_DESCRIPTION" "Enter a short package description or a file path:")
    your_name=$(get_value "YOUR_NAME" "Enter your username:")
    your_email=$(get_value "YOUR_EMAIL" "Enter your email:")
else
    echo "Enter your package name:"
    read package_name
    echo "Enter a short package description or a file path:"
    read package_description
    echo "Enter your username:"
    read your_name
    echo "Enter your email:"
    read your_email
fi

# If package_description is a file, read its contents
if [ -f "$package_description" ]; then
    package_description=$(cat "$package_description")
fi

module_path=$(zenity --file-selection --directory --title="Select your existing local module")

cp -r "$module_path" "./$package_name"
cd $package_name || exit 1

echo "Creating necessary files..."
touch setup.py
touch README.md
touch .gitignore

cat <<EOT >> setup.py
from setuptools import setup, find_packages

setup(
    name="$package_name",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        # Add your package dependencies here
    ],
    author="$your_name",
    author_email="$your_email",
    description="$package_description",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/your_username/$package_name",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
    ],
)
EOT

echo "# $package_name" >> README.md

echo "Packaging your code..."
python3 setup.py sdist bdist_wheel

echo "Uploading your package to PyPI..."
twine upload dist/* --username "$your_name" --password "$(zenity --password --title='Enter your PyPI password')"

echo "Package uploaded to PyPI successfully!"
