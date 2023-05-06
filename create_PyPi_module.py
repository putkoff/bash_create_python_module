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
    package_description=$(get_value "PACKAGE_DESCRIPTION" "Enter a short package description:")
    your_name=$(get_value "YOUR_NAME" "Enter your name:")
    your_email=$(get_value "YOUR_EMAIL" "Enter your email:")
else
    echo "Enter your package name:"
    read package_name
    echo "Enter a short package description:"
    read package_description
    echo "Enter your name:"
    read your_name
    echo "Enter your email:"
    read your_email
fi

mkdir $package_name
cd $package_name

echo "Creating necessary files..."
touch setup.py
touch README.md
touch .gitignore
mkdir $package_name
touch $package_name/__init__.py

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
twine upload dist/*

echo "Package uploaded to PyPI successfully!"
