#!/bin/bash

# Array of parameters
params=(
    "100 10 5"

    # Add more parameter combinations as needed
)


# Clear the output file
> output.txt

# Loop through the parameter array
for param in "${params[@]}"; do
    # Execute the command and append the output to output.txt
    sage identifying_ideal_lattice.sage $param >> output.txt
done
