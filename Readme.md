# Home Video Converter

Simple script to convert a folder of videos using ffmpeg for use with a media server such as Plex.

- Converts videos using the h.264 and aac codecs
- Retains the original file creation and modified dates (for sorting)
- Sets video title and date metadata values based on the file name and modified date

Note on dates. Plex uses the file modified date for sorting this type of content. If your creation and modified dates differ from each other, you may prefer to modify the script and use the creation everywhere.

## Instructions (macOS)

1. Install ffmpeg using Homebrew `brew install ffmpeg`
2. Install Xcode command line tools with `xcode-select --install`. This is for the `SetFile` command.
3. `chmod +x convert.sh`
4. `./convert.sh <input-folder> <output-folder>`

## Encoding Settings

The following settings are used. These could be changed based on the input content (lower crf for low quality originals, audio could be copied rather than re-encoded, etc), however, they are more of a catch all and worked for my use case.

- **-c:v libx264** sets the Video Codec to libx264 (H.264)
- **-crf 20** sets the Constant Rate Factor to 20 for video quality
- **-preset slow** sets the Encoding Preset to "slow" for better quality
- **-c:a aac** sets the audio codec to AAC
- **-b:a** sets the audio birate to that of the original file (or 160k)

## Potential Improvements

This script is meant to be an assistant to some manual work, but it could be more robust. Some potential improvements:

- Handle duplicates. If two input files have the same name with different extensions, the second output will overwrite the first since the extensions will both be .mp4
- Filter input files by type as well as skipping files that are already encoded appropriately
- Process files in parallel
- Date handling options
