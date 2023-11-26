#!/bin/bash

file=$1

input_time=$2

out_time=$3

file_extension="${file##*.}"

to_path=$4

output_name=$5

# echo $file

# echo $input_time

# echo $out_time

# echo $file_extension

# echo $output_name

# input time to seconds

IFS=: read -r input_hours input_minutes input_seconds <<< "$input_time"
input_total_seconds=$((input_hours * 3600 + input_minutes * 60 + input_seconds))

# out time to seconds
IFS=: read -r out_hours out_minutes out_seconds <<< "$out_time"
out_total_seconds=$((out_hours * 3600 + out_minutes * 60 + out_seconds))

# difference in seconds
time_diff=$((out_total_seconds - input_total_seconds))

# time difference back to HH:MM:SS
diff_hours=$((time_diff / 3600))
diff_minutes=$(( (time_diff % 3600) / 60 ))
diff_seconds=$((time_diff % 60))

formatted_diff=$(printf "%d:%02d:%02d" $diff_hours $diff_minutes $diff_seconds)
#echo "Difference: $formatted_diff"

if [ -z "$output_name" ]; then
    output_file="output.$file_extension"
    echo $output_file
else
    output_file="$output_name.$file_extension"
    echo $output_file
fi

ffmpeg -i "$file" -ss "$input_time" -t "$formatted_diff" -c copy "$to_path/$output_file"