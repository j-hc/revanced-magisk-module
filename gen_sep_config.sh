#!/bin/bash

# Check for correct number of arguments
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <config_file> <key_to_match> <output_file>"
    exit 1
fi

config_file=$1
key_to_match=$2
output_file=$3

# Function to extract the section based on the key
extract_section() {
    awk -v key="$key_to_match" '
        BEGIN { print "[" key "]" }  # Print the key at the beginning
        /^\[/ && tolower($1) == "[" tolower(key) "]" { in_section = 1; next }
        /^\[/ { in_section = 0 }
        in_section == 1
    ' "$config_file"
}

# Extract the desired section
section_content=$(extract_section)

# Check if the section was found
if [[ -z "$section_content" ]]; then
    echo "Key '$key_to_match' not found in the config file."
    exit 1
fi

# Write the extracted section to the output file
echo "$section_content" > "$output_file"

echo "Section for '$key_to_match' written to $output_file"
