#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_folder_path> <output_folder_path>"
    exit 1
fi

INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"

if [ ! -d "$INPUT_FOLDER" ]; then
    echo "Error: Input folder '$INPUT_FOLDER' does not exist."
    exit 1
fi

if [ ! -d "$OUTPUT_FOLDER" ]; then
    echo "Creating output folder: '$OUTPUT_FOLDER'"
    mkdir -p "$OUTPUT_FOLDER"
fi

for FILE_PATH in "$INPUT_FOLDER"/*; do
    if [[ -f "$FILE_PATH" ]]; then
        echo "Processing file: $FILE_PATH"
        
        CREATION_DATE_FOR_FILE=$(stat -f "%SB" -t "%m/%d/%Y %H:%M:%S" "$FILE_PATH")
        MODIFIED_DATE_FOR_FILE=$(stat -f "%Sm" -t "%m/%d/%Y %H:%M:%S" "$FILE_PATH")
        DATE_FOR_METADATA=$(stat -f "%Sm" -t "%Y-%m-%d" "$FILE_PATH")

        FILENAME=$(basename -- "$FILE_PATH")
        NAME_ONLY="${FILENAME%.*}"
        EXTENSION="${FILENAME##*.}"
        echo "Original file extension: $EXTENSION"

        NEW_FILE_PATH="$OUTPUT_FOLDER/$NAME_ONLY.mp4"

        AUDIO_BITRATE=$(ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$FILE_PATH")
        if [[ -z "$AUDIO_BITRATE" ]]; then
            AUDIO_BITRATE=160k
            echo "Using default audio bitrate for $FILENAME: $AUDIO_BITRATE"
        else
            AUDIO_BITRATE="${AUDIO_BITRATE}k"
            echo "Detected audio bitrate for $FILENAME: $AUDIO_BITRATE"
        fi

        echo "Converting with ffmpeg: $FILE_PATH -> $NEW_FILE_PATH"
        ffmpeg -i "$FILE_PATH" -c:v libx264 -crf 20 -preset slow -c:a aac -b:a "$AUDIO_BITRATE" -metadata title="$NAME_ONLY" -metadata date="$DATE_FOR_METADATA" -movflags faststart "$NEW_FILE_PATH"

        # `SetFile` expects: "MM/DD/YYYY HH:MM:SS" format
        echo "Restoring creation date for $NEW_FILE_PATH: $CREATION_DATE_FOR_FILE"
        SetFile -d "$CREATION_DATE_FOR_FILE" "$NEW_FILE_PATH"

        # `SetFile` expects: "MM/DD/YYYY HH:MM:SS" format
        echo "Restoring modified date for $NEW_FILE_PATH: $MODIFIED_DATE_FOR_FILE"
        SetFile -m "$MODIFIED_DATE_FOR_FILE" "$NEW_FILE_PATH"

        echo "Finished processing $FILENAME"
        echo "-------------------------"
    fi
done

echo "Processing completed."
