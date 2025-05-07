# Screen Recording Script for Cinnamon Desktop

A bash script for recording a specific region of your Linux desktop with separate audio tracks for easy editing. Perfect for creating YouTube-ready content without requiring a dedicated video editor.

## Features

- Record a custom-sized region (default 1920x1080) from your desktop
- Automatically centers the recording area (or specify custom coordinates)
- Creates separate high-quality audio file for editing in Audacity
- Provides commands for combining the video with edited audio
- Produces YouTube-optimized output files

## Requirements

- FFmpeg
- Audacity (for audio editing)
- Bash shell
- Desktop environment (script may work with other desktops / window manager but is untested)

## Installation

1. Download the script:

```bash
wget https://example.com/screen_recording_script.sh
# or
curl -O https://example.com/screen_recording_script.sh
```

2. Make it executable:

```bash
chmod +x screen_recording_script.sh
```

## Basic Usage

1. Run the script with default settings:

```bash
./screen_recording_script.sh
```

2. This will:
   - Create a new project folder in your current directory (named `recording_TIMESTAMP`)
   - Record a 1920x1080 region centered on your screen
   - Save the video and separate audio files to this project folder
   - Provide instructions for next steps after recording

## Command-Line Options

```
Usage: ./screen_recording_script.sh [options]
Options:
  -h, --help              Show this help message
  -o, --output NAME       Set project folder name (default: recording_TIMESTAMP)
  -x, --x-offset PIXELS   Set X offset for capture region (default: centered)
  -y, --y-offset PIXELS   Set Y offset for capture region (default: centered)
  -d, --duration SECONDS  Set recording duration (default: until stopped with Ctrl+C)
  -f, --fps NUMBER        Set frames per second (default: 30)
  -a, --audio DEVICE      Set audio input device (default: default)
  -l, --list-devices      List available audio input devices
```

## Examples

Record for exactly 10 minutes:
```bash
./screen_recording_script.sh -d 600
```

Record upper-left corner of screen:
```bash
./screen_recording_script.sh -x 0 -y 0
```

Use specific audio device and custom project name:
```bash
./screen_recording_script.sh -a alsa_input.pci-0000_00_1f.3.analog-stereo -o my_tutorial
```
This will create a `my_tutorial` folder in your current directory.

List available audio devices:
```bash
./screen_recording_script.sh -l
```

## Complete Workflow

### 1. Recording

Run the script and press Enter to start recording. Press `q` to stop the recording (if no duration was specified).

### 2. Editing Audio

1. Open the generated `.flac` file in Audacity:
   ```bash
   audacity ./recording_*/screen_recording_audio.flac
   # or for custom named projects:
   audacity ./my_tutorial/screen_recording_audio.flac
   ```

2. Edit your audio as needed (noise reduction, normalization, compression, etc.)

3. Export the edited audio as a WAV file (File → Export → Export as WAV)
   - Save it with the same name but with `_edited` suffix
   - Use the same directory as the original files

### 3. Combining Video with Edited Audio

Run the provided FFmpeg command to create a YouTube-ready MP4 file:

```bash
ffmpeg -i "./recording_*/screen_recording.mkv" -i "./recording_*/screen_recording_edited.wav" \
   -map 0:v -map 1:a -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
   -c:a aac -b:a 192k -ar 48000 -movflags +faststart \
   "./recording_*/screen_recording_youtube.mp4"
```

This command will:
- Take the original video
- Replace its audio with your edited audio
- Optimize the file for YouTube upload

### 4. Trimming (Optional)

If you need to trim your video (e.g., remove the first 10 seconds and keep 5 minutes), use:

```bash
ffmpeg -i "./recording_*/screen_recording.mkv" -i "./recording_*/screen_recording_edited.wav" \
   -map 0:v -map 1:a -ss 00:00:10 -t 00:05:00 \
   -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
   -c:a aac -b:a 192k -ar 48000 -movflags +faststart \
   "./recording_*/screen_recording_youtube.mp4"
```

## Project Organization

The script creates a new project folder for each recording session:

```
my_tutorial/
├── screen_recording.mkv       # Original video with audio
├── screen_recording_audio.flac  # Separate high-quality audio for editing
├── screen_recording_edited.wav  # Your edited audio (created in Audacity)
└── screen_recording_youtube.mp4 # Final output for YouTube
```

This approach makes it easy to:
- Keep all files related to one recording session together
- Work on multiple projects without mixing files
- Archive or share entire projects as needed

## Tips for Best Results

1. **Audio Quality:**
   - When recording, make sure your microphone is properly positioned
   - Use headphones to prevent speaker feedback
   - Record in a quiet environment

2. **Video Quality:**
   - Ensure your desktop is clean and organized before recording
   - Use a theme with good contrast for visibility
   - Consider increasing font sizes for better readability

3. **Performance:**
   - Close unnecessary applications before recording
   - If recording is choppy, try lowering the FPS (e.g., `-f 24`)
   - For longer recordings, monitor your disk space

4. **YouTube Settings:**
   - The output file is already optimized for YouTube
   - Recommended upload settings: 1080p, Standard license
   - Add tags, description, and timestamps for better discoverability

## Troubleshooting

### No Audio in Recording

Check available audio devices and specify the correct one:
```bash
./screen_recording_script.sh -l
./screen_recording_script.sh -a your_device_name
```

### Poor Performance or Choppy Recording

Try reducing the FPS or recording area size:
```bash
./screen_recording_script.sh -f 24
```

### FFmpeg Not Found

Install FFmpeg:
```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# Fedora
sudo dnf install ffmpeg

# Arch Linux
sudo pacman -S ffmpeg
```

## License

This script is provided under the MIT License. Feel free to modify and distribute it as needed.

## Acknowledgments

- FFmpeg for the excellent audio/video tools
- Audacity for audio editing capabilities
