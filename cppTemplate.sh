#!/bin/bash

# Prompt the user for the project name
read -p "Enter the name of your C++ project: " project_name

# Create the project directory and nested src folder
mkdir -p "$project_name/src"

# Move into the project directory
cd "$project_name" || exit 1

# Create a basic main.cpp file inside src
cat <<EOL > src/main.cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
EOL

echo "C++ project '$project_name' created with main.cpp in $(pwd)/src"
