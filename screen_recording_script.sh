#!/bin/bash

# Script to record a specific region of the Cinnamon desktop
# Creates video with separate audio file for easy editing

# Default settings
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROJECT_NAME="recording_$TIMESTAMP"
OUTPUT_DIR="$(pwd)/$PROJECT_NAME"
OUTPUT_NAME="screen_recording"
CAPTURE_WIDTH=1920
CAPTURE_HEIGHT=1080
FPS=30
AUDIO_DEVICE="default"
DURATION=0  # 0 means record until stopped

# Create project directory in current location
mkdir -p "$OUTPUT_DIR"
echo "Created project directory: $OUTPUT_DIR"

# Function to display usage information
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -o, --output NAME       Set output filename (default: screen_recording_TIMESTAMP)"
    echo "  -x, --x-offset PIXELS   Set X offset for capture region (default: centered)"
    echo "  -y, --y-offset PIXELS   Set Y offset for capture region (default: centered)"
    echo "  -d, --duration SECONDS  Set recording duration (default: until stopped with Ctrl+C)"
    echo "  -f, --fps NUMBER        Set frames per second (default: 30)"
    echo "  -a, --audio DEVICE      Set audio input device (default: default)"
    echo "  -l, --list-devices      List available audio input devices"
    echo ""
    echo "Press q to stop recording if no duration is specified."
}

# Function to list audio devices
list_audio_devices() {
    echo "Available audio input devices:"
    ffmpeg -hide_banner -sources pulse 2>&1 | grep "pulse" | grep -v "alsa"
}

# Process command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            PROJECT_NAME="$2"
            OUTPUT_DIR="$(pwd)/$PROJECT_NAME"
            shift 2
            ;;
        -x|--x-offset)
            X_OFFSET="$2"
            shift 2
            ;;
        -y|--y-offset)
            Y_OFFSET="$2"
            shift 2
            ;;
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -f|--fps)
            FPS="$2"
            shift 2
            ;;
        -a|--audio)
            AUDIO_DEVICE="$2"
            shift 2
            ;;
        -l|--list-devices)
            list_audio_devices
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Calculate default position if not specified (centered)
if [ -z "$X_OFFSET" ]; then
    X_OFFSET=$(( (3440 - CAPTURE_WIDTH) / 2 ))
fi

if [ -z "$Y_OFFSET" ]; then
    Y_OFFSET=$(( (1440 - CAPTURE_HEIGHT) / 2 ))
fi

echo "=== Screen Recording Setup ==="
echo "Recording area: ${CAPTURE_WIDTH}x${CAPTURE_HEIGHT} at position (${X_OFFSET},${Y_OFFSET})"
echo "Output: $OUTPUT_DIR/$OUTPUT_NAME"
echo "FPS: $FPS"
echo "Audio device: $AUDIO_DEVICE"
if [ "$DURATION" -gt 0 ]; then
    echo "Duration: $DURATION seconds"
else
    echo "Duration: Until stopped (press q to stop)"
fi
echo "============================="
echo "Press Enter to start recording..."
read

# Record video and audio separately
echo "Recording started. Press q to stop..."

# Set duration parameter if specified
DURATION_PARAM=""
if [ "$DURATION" -gt 0 ]; then
    DURATION_PARAM="-t $DURATION"
fi

# Record screen - using slightly more compatible settings for later editing
ffmpeg -hide_banner -loglevel error \
    -f x11grab -video_size ${CAPTURE_WIDTH}x${CAPTURE_HEIGHT} -framerate $FPS \
    -i :0.0+${X_OFFSET},${Y_OFFSET} \
    -f pulse -i $AUDIO_DEVICE \
    -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
    -c:a aac -b:a 192k \
    $DURATION_PARAM \
    "$OUTPUT_DIR/${OUTPUT_NAME}.mkv" \
    -c:a flac \
    "$OUTPUT_DIR/${OUTPUT_NAME}_audio.flac"

echo "Recording completed!"
echo "Video saved as: $OUTPUT_DIR/${OUTPUT_NAME}.mkv"
echo "Audio saved as: $OUTPUT_DIR/${OUTPUT_NAME}_audio.flac"
echo ""
echo "Next steps:"
echo "1. Edit audio in Audacity: $OUTPUT_DIR/${OUTPUT_NAME}_audio.flac"
echo "2. Export edited audio as: $OUTPUT_DIR/${OUTPUT_NAME}_edited.wav"
echo "3. Run the following command to combine them for YouTube upload:"
echo ""
echo "   # For direct YouTube upload (recommended):"
echo "   ffmpeg -i \"$OUTPUT_DIR/${OUTPUT_NAME}.mkv\" -i \"$OUTPUT_DIR/${OUTPUT_NAME}_edited.wav\" \\"
echo "      -map 0:v -map 1:a -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \\"
echo "      -c:a aac -b:a 192k -ar 48000 -movflags +faststart \\"
echo "      \"$OUTPUT_DIR/${OUTPUT_NAME}_youtube.mp4\""
echo ""
echo "   # If you need to trim the video at the same time (example starts at 10s and takes 5 minutes):"
echo "   ffmpeg -i \"$OUTPUT_DIR/${OUTPUT_NAME}.mkv\" -i \"$OUTPUT_DIR/${OUTPUT_NAME}_edited.wav\" \\"
echo "      -map 0:v -map 1:a -ss 00:00:10 -t 00:05:00 \\"
echo "      -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \\"
echo "      -c:a aac -b:a 192k -ar 48000 -movflags +faststart \\"
echo "      \"$OUTPUT_DIR/${OUTPUT_NAME}_youtube.mp4\""
