#!/bin/bash

echo "=====Welcome to Shell Video Cutter====="

if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install ffmpeg and try again."
    exit 1
fi

echo "Do you want to cut a video or join videos?"
read option

if [ -z "$option" ]; then
    echo "Error: Please provide an input!"
    exit 1
fi

if [ "$option" == "cut" ]; then
    echo "Enter the path to the video file:"

    read -e file

    if [ -z "$file" ]; then
        echo "Error: Please provide an input!"
        exit 1
    fi

    file_extension="${file##*.}"

    echo "From: HH:MM:SS"
    read input_time

    echo "To: HH:MM:SS"
    read out_time

    # Convert input time to seconds
    IFS=: read -r input_hours input_minutes input_seconds <<< "$input_time"
    input_total_seconds=$((input_hours * 3600 + input_minutes * 60 + input_seconds))

    # Convert out time to seconds
    IFS=: read -r out_hours out_minutes out_seconds <<< "$out_time"
    out_total_seconds=$((out_hours * 3600 + out_minutes * 60 + out_seconds))

    # Calculate the difference in seconds
    time_diff=$((out_total_seconds - input_total_seconds))

    # Convert the time difference back to HH:MM:SS
    diff_hours=$((time_diff / 3600))
    diff_minutes=$(( (time_diff % 3600) / 60 ))
    diff_seconds=$((time_diff % 60))

    formatted_diff=$(printf "%d:%02d:%02d" $diff_hours $diff_minutes $diff_seconds)
    echo "Difference: $formatted_diff"

    output_file="output.$file_extension"
    echo "Output file (Press Enter to use default 'output.$file_extension'):"
    read custom_output_file

    if [ -n "$custom_output_file" ]; then
        output_file=$custom_output_file
    fi

    ffmpeg -i "$file" -ss "$input_time" -t "$formatted_diff" -c copy "$output_file"

    echo "Cutting complete. Output saved to: $(pwd)/$output_file"

elif [ "$option" == "join" ]; then
    echo "Enter the paths of the video files to join (separated by space):"
    read -e -a video_files

    if [ "${#video_files[@]}" -lt 2 ]; then
        echo "Error: Please provide at least two video files to join."
        exit 1
    fi

    # Create a temporary file listing the paths of the videos to join
    temp_list_file=$(mktemp)
    for video_file in "${video_files[@]}"; do
        echo "file '$video_file'" >> "$temp_list_file"
    done

    output_file="output_joined.$file_extension"
    echo "Output file (Press Enter to use default 'output_joined.$file_extension'):"
    read custom_output_file

    if [ -n "$custom_output_file" ]; then
        output_file=$custom_output_file
    fi

    ffmpeg -f concat -safe 0 -i "$temp_list_file" -c copy "$output_file"

    rm "$temp_list_file"

    echo "Joining complete. Output saved to: $(pwd)/$output_file"
else
    echo "Error: Invalid option. Please choose 'cut' or 'join'."
    exit 1
fi

