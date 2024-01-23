#!/bin/bash

# Array of parameters
params=(
    "100 5 5"
    "150 5 5"
    "350 20 5"
    "200 5 5"
    "250 5 5"
    "300 5 5"
    "350 5 5"
    "400 5 5"
    "450 5 5"
    "500 5 5"

    # Add more parameter combinations as needed
)

# Clear the output file
> output.txt

# Loop through the parameter array
for param in "${params[@]}"; do
    # Execute the command and append the output to output.txt
    sage identifying_ideal_lattice.sage $param >> output.txt
done
