#!/bin/bash

# A script to vertically stack multiple images using ffmpeg.
# Usage: ./image-vstack.sh <input_image1> <input_image2> ... <output_image>

# 1. VALIDATE INPUT
# Check if at least two arguments (one input, one output) are provided.
if [ "$#" -lt 2 ]; then
    echo "❌ Error: Not enough arguments supplied."
    echo "Usage: $0 <input_image1> <input_image2> ... <output_image>"
    echo "Example: $0 frame1.png frame2.png final_stack.png"
    exit 1
fi

# 2. PREPARE VARIABLES
# The last argument is the output file.
output_file="${!#}"

# All arguments except the last one are the input files.
inputs=("${@:1:$#-1}")
num_inputs=${#inputs[@]}

# Initialize arrays and strings for building the command.
ffmpeg_inputs=()
filter_chain=""

# 3. BUILD FFMPEG COMMAND ARGUMENTS
# Loop through the input files to build the `-i` and filter parts of the command.
# The index 'i' corresponds to ffmpeg's input stream index (0, 1, 2...).
for i in "${!inputs[@]}"; do
    # Add each input file to an array for ffmpeg.
    ffmpeg_inputs+=("-i" "${inputs[$i]}")
    # Append the corresponding stream specifier to the filter string (e.g., [0:v], [1:v]).
    filter_chain+="[$i:v]"
done

# Complete the filter_complex string with the vstack filter and output label [v].
filter_complex_str="${filter_chain}vstack=inputs=${num_inputs}[v]"

# 4. EXECUTE THE COMMAND
echo "⏳ Combining $num_inputs images into '$output_file'..."

# Execute the ffmpeg command.
# Using an array ("${ffmpeg_inputs[@]}") ensures that filenames with spaces are handled correctly.
ffmpeg -loglevel error "${ffmpeg_inputs[@]}" -filter_complex "$filter_complex_str" -map "[v]" "$output_file"

# Check the exit code of ffmpeg to confirm success or failure.
if [ $? -eq 0 ]; then
    echo "✅ Success! Image saved as '$output_file'."
else
    echo "❌ Error: The ffmpeg command failed."
    exit 1
fi