#!/bin/bash

# --- media-tool.sh ---
# A menu-driven bash script for common media editing tasks using FFmpeg.

# --- Configuration ---
PRESET_FILE="$HOME/.media_tool_presets"

# --- Colors for UI ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

# --- Prerequisite Check ---
command -v ffmpeg >/dev/null 2>&1 || { echo -e "${C_RED}Error: ffmpeg is not installed. Please install it to use this script.${C_RESET}"; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { echo -e "${C_RED}Error: ffprobe is not installed. Please install it to use this script.${C_RESET}"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e "${C_RED}Error: jq is not installed. Please install it to use this script.${C_RESET}"; exit 1; }

# --- File Handling ---
INPUT_FILE="$1"
if [[ -z "$INPUT_FILE" ]]; then
    echo -e "${C_RED}Usage: $0 <media_file>${C_RESET}"
    exit 1
fi
if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${C_RED}Error: File not found: '$INPUT_FILE'${C_RESET}"
    exit 1
fi

BASE_NAME=$(basename -- "$INPUT_FILE")
DIR_NAME=$(dirname -- "$INPUT_FILE")
FILE_NAME="${BASE_NAME%.*}"
FILE_EXT="${BASE_NAME##*.}"

# --- Global variables for persistent info header ---
INFO_DURATION=""
INFO_SIZE=""
INFO_RESOLUTION=""
INFO_TRACKS=""

# --- Helper Functions ---

gather_media_info() {
    local info=$(ffprobe -v quiet -print_format json -show_format -show_streams "$INPUT_FILE")
    
    local duration=$(echo "$info" | jq -r '.format.duration | tonumber | floor')
    local size=$(echo "$info" | jq -r '.format.size | tonumber')
    INFO_RESOLUTION=$(echo "$info" | jq -r '.streams[] | select(.codec_type=="video") | "\(.width)x\(.height)"' | head -n 1)

    local seconds=$((duration % 60)); local minutes=$((duration / 60 % 60)); local hours=$((duration / 3600))
    INFO_DURATION=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
    INFO_SIZE=$(numfmt --to=iec-i --suffix=B --format="%.2f" $size)
    
    # Store formatted track list in a multi-line variable
    INFO_TRACKS=$(echo "$info" | jq -r '.streams[] | "  - Stream #\(.index): \(.codec_type) (\(.codec_name))"')
}

show_header() {
    clear
    echo -e "${C_BLUE}${C_BOLD}--- FFmpeg Media Tool ---${C_RESET}"
    echo "-----------------------------------------------------"
    echo -e "File:         ${C_YELLOW}$BASE_NAME${C_RESET}"
    echo -e "Duration:     ${INFO_DURATION}"
    echo -e "Size:         ${INFO_SIZE}"
    [[ -n "$INFO_RESOLUTION" ]] && echo -e "Resolution:   ${INFO_RESOLUTION}"
    echo -e "${C_BOLD}Tracks:${C_RESET}"
    echo -e "${INFO_TRACKS}"
    echo "-----------------------------------------------------"
    echo
}

execute_ffmpeg() {
    local cmd="$1"
    echo
    echo -e "${C_YELLOW}The following FFmpeg command will be executed:${C_RESET}"
    echo -e "${C_GREEN}$cmd${C_RESET}"
    echo
    read -p "Do you want to continue? (y/N) " confirm
    if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
        eval "$cmd"
        echo -e "\n${C_GREEN}Operation completed successfully!${C_RESET}"
    else
        echo -e "\n${C_RED}Operation cancelled.${C_RESET}"
    fi
    read -p "Press Enter to return to the menu..."
}

# --- Feature Functions ---

transcode_media() {
    show_header
    echo -e "${C_BOLD}--- Transcode Media ---${C_RESET}"
    
    read -p "Enter output container (e.g., mp4, mkv): " container
    read -p "Enter video codec (e.g., libx264, libx265, copy): " vcodec
    
    local video_opts=""
    if [[ "$vcodec" != "copy" ]]; then
        read -p "Enter CRF (quality, 0-51, lower is better, e.g., 23): " crf
        read -p "Enter preset (speed, e.g., slow, medium, fast): " preset
        read -p "Enter resolution (e.g., 1920x1080, 1280x-1, or leave empty): " resolution
        
        video_opts="-c:v $vcodec -crf $crf -preset $preset"
        # FIXED: Replace 'x' with ':' for the scale filter
        if [[ -n "$resolution" ]]; then
            video_opts="$video_opts -vf scale=${resolution//x/:}"
        fi
    else
        video_opts="-c:v copy"
    fi

    read -p "Enter audio codec (e.g., aac, ac3, copy): " acodec
    read -p "Enter audio bitrate (e.g., 128k, 192k, or leave empty): " abrate

    local audio_opts=""
    if [[ "$acodec" != "copy" ]]; then
        audio_opts="-c:a $acodec"
        [[ -n "$abrate" ]] && audio_opts="$audio_opts -b:a $abrate"
    else
        audio_opts="-c:a copy"
    fi

    OUTPUT_FILE="${DIR_NAME}/${FILE_NAME}_transcoded.${container}"
    CMD="ffmpeg -i \"$INPUT_FILE\" $video_opts $audio_opts -map_metadata 0 \"$OUTPUT_FILE\""
    execute_ffmpeg "$CMD"
}

extract_track() {
    show_header
    echo -e "${C_BOLD}--- Extract a Track ---${C_RESET}"
    echo "Available tracks are listed in the header."
    echo
    read -p "Enter the stream index to extract: " stream_index
    read -p "Enter output file name (e.g., audio.aac, video.mkv): " out_name
    OUTPUT_FILE="${DIR_NAME}/${out_name}"
    CMD="ffmpeg -i \"$INPUT_FILE\" -map 0:${stream_index} -c copy -map_metadata 0 \"$OUTPUT_FILE\""
    execute_ffmpeg "$CMD"
}

cut_media() {
    show_header
    echo -e "${C_BOLD}--- Cut Media File ---${C_RESET}"
    read -p "Enter start time (HH:MM:SS): " start_time
    read -p "Enter duration (HH:MM:SS): " duration
    OUTPUT_FILE="${DIR_NAME}/${FILE_NAME}_cut.${FILE_EXT}"
    CMD="ffmpeg -i \"$INPUT_FILE\" -ss \"$start_time\" -t \"$duration\" -c copy -map_metadata 0 \"$OUTPUT_FILE\""
    execute_ffmpeg "$CMD"
}

normalize_audio() {
    show_header
    echo -e "${C_BOLD}--- Normalize Audio (2-Pass) ---${C_RESET}"
    echo "Analyzing audio... this may take a moment."
    
    local loudnorm_stats=$(ffmpeg -i "$INPUT_FILE" -af loudnorm=I=-16:LRA=11:print_format=json -f null - 2>&1 | tail -n 12 | grep -v 'progress' | jq -r '"measured_I=\(.input_i):measured_LRA=\(.input_lra):measured_tp=\(.input_tp):measured_thresh=\(.input_thresh):offset=\(.target_offset)"')
    
    if [[ -z "$loudnorm_stats" || "$loudnorm_stats" == *"null"* ]]; then
        echo -e "${C_RED}Failed to analyze audio. The file might not have an audio stream.${C_RESET}"
        read -p "Press Enter to return..."
        return
    fi

    echo "Analysis complete. Ready to apply normalization."
    OUTPUT_FILE="${DIR_NAME}/${FILE_NAME}_normalized.${FILE_EXT}"
    CMD="ffmpeg -i \"$INPUT_FILE\" -af \"loudnorm=I=-16:LRA=11:${loudnorm_stats}\" -c:v copy -map_metadata 0 \"$OUTPUT_FILE\""
    execute_ffmpeg "$CMD"
}

convert_audio() {
    show_header
    echo -e "${C_BOLD}--- Audio Conversion (Extract & Convert) ---${C_RESET}"
    read -p "Enter target audio format (e.g., mp3, aac, flac): " aformat
    read -p "Enter audio bitrate (e.g., 192k, 256k, 320k): " abrate
    
    local acodec
    case "$aformat" in
        mp3) acodec="libmp3lame" ;;
        aac) acodec="aac" ;;
        flac) acodec="flac" ;;
        *) echo -e "${C_YELLOW}Warning: Unknown format. Using '$aformat' as the codec name.${C_RESET}"; acodec="$aformat" ;;
    esac

    OUTPUT_FILE="${DIR_NAME}/${FILE_NAME}_audio.${aformat}"
    CMD="ffmpeg -i \"$INPUT_FILE\" -vn -c:a $acodec -b:a $abrate -map_metadata 0 \"$OUTPUT_FILE\""
    execute_ffmpeg "$CMD"
}

adjust_volume() {
    show_header
    echo -e "${C_BOLD}--- Adjust Volume ---${C_RESET}"
    read -p "Enter volume multiplier (e.g., 1.5 for 150%, 0.5 for 50%): " vol
    OUTPUT_FILE="${DIR_NAME}/${FILE_NAME}_volume.${FILE_EXT}"
    CMD="ffmpeg -i \"$INPUT_FILE\" -af \"volume=${vol}\" -c:v copy -map_metadata 0 \"$OUTPUT_FILE\""
    execute_ffmpeg "$CMD"
}

batch_operations() {
    show_header
    echo -e "${C_BOLD}--- Batch Operations ---${C_RESET}"
    echo "This feature is experimental. Please backup your files."
    echo "Batch operations function is currently a placeholder."
    read -p "Press Enter to return..."
}

# --- Main Program Flow ---

# 1. Gather media info to be displayed in the header
gather_media_info

# 2. Start the main menu loop
while true; do
    show_header
    echo -e "${C_BOLD}Select an operation:${C_RESET}"
    echo "1) Transcode (Change format, codec, resolution)"
    echo "2) Extract a Track (e.g., audio, subtitles)"
    echo "3) Cut Media (by start time and duration)"
    echo "4) Normalize Audio (EBU R128 standard)"
    echo "5) Convert to Audio (Extract audio to mp3, flac, etc.)"
    echo "6) Adjust Volume"
    echo "7) Batch Operations (Perform an action on multiple files)"
    echo "8) Exit"
    echo
    read -p "Enter your choice [1-8]: " choice

    case $choice in
        1) transcode_media ;;
        2) extract_track ;;
        3) cut_media ;;
        4) normalize_audio ;;
        5) convert_audio ;;
        6) adjust_volume ;;
        7) batch_operations ;;
        8) exit 0 ;;
        *) echo -e "${C_RED}Invalid option. Please try again.${C_RESET}"; sleep 1 ;;
    esac
done