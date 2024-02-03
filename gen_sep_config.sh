#!/bin/bash

# Parse the TOML file
config_file=$1
key_to_match=$2
output_file=$3

# Function to extract table names
extract_tables() {
    awk -F '[][]' '/\[.*\]/{print $2}' "$config_file"
}

# Function to extract content for each table and create separate files
extract_content() {
    while IFS= read -r table; do
        # Remove leading/trailing whitespace and quotes
        table=$(echo "$table" | sed 's/^ *//;s/ *$//;s/^"\|"$//g')
        # if the table name is not equal to the key to match, skip
        if [ "$table" != "$key_to_match" ]; then
            continue
        fi
        # Create a file with the table name and write the content
        awk -v table="$table" -v in_table=0 '/^\['"$table"'\]/{in_table=1; next} /^\[.*\]/{in_table=0} in_table && NF {print $1" = "$3}' "$config_file" > "$output_file"
        # append [$table] to the first line of the file
        sed -i "1s/^/[${table}]\n/" "$output_file"

        # add file prefix string to the file
        sed -i "1s/^/# This file is generated from $config_file\n/" "$output_file"
        # if file is generated, exit the loop
        if [ -f "$output_file" ]; then
            break
        fi
    done
}

# Main script
extract_tables | extract_content

echo "Separate TOML files created for each table with matching keys."
