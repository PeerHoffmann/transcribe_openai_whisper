#!/bin/bash

# OpenAI Whisper Transcription Script
# Version: 1.1.2
# Author: Peer Hoffmann
# Repository: https://github.com/PeerHoffmann/transcribe_openai_whisper

# === CONFIGURATION LOADING ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Error: Configuration file 'config.json' not found!"
    echo "Please copy config.json.example to config.json and adjust your settings."
    exit 1
fi

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is required for configuration parsing but not installed."
    echo "Please install jq: sudo apt install jq (Ubuntu/Debian) or brew install jq (macOS)"
    exit 1
fi

# Load configuration from JSON
AUDIO_DIR=$(jq -r '.audio_dir' "$CONFIG_FILE")
OUTPUT_DIR=$(jq -r '.output_dir' "$CONFIG_FILE")
WHISPER_MODEL=$(jq -r '.whisper_model' "$CONFIG_FILE")
BRAND_PROMPT=$(jq -r '.brand_prompt' "$CONFIG_FILE")
CHECK_FOR_UPDATES=$(jq -r '.check_for_updates' "$CONFIG_FILE")

# Load advanced settings
NO_SPEECH_THRESHOLD=$(jq -r '.advanced_settings.no_speech_threshold' "$CONFIG_FILE")
LOGPROB_THRESHOLD=$(jq -r '.advanced_settings.logprob_threshold' "$CONFIG_FILE")
COMPRESSION_RATIO_THRESHOLD=$(jq -r '.advanced_settings.compression_ratio_threshold' "$CONFIG_FILE")
CONDITION_ON_PREVIOUS_TEXT=$(jq -r '.advanced_settings.condition_on_previous_text' "$CONFIG_FILE")
TIMEOUT_SECONDS=$(jq -r '.advanced_settings.timeout_seconds' "$CONFIG_FILE")
ENABLE_TIMEOUT=$(jq -r '.advanced_settings.enable_timeout' "$CONFIG_FILE")
VERBOSE=$(jq -r '.advanced_settings.verbose' "$CONFIG_FILE")

# Validate required configuration
if [[ "$AUDIO_DIR" == "enter_your_audio_directory_here" ]] || [[ "$OUTPUT_DIR" == "enter_your_output_directory_here" ]]; then
    echo "❌ Error: Please configure your audio_dir and output_dir in config.json"
    exit 1
fi

# === UPDATE CHECKING ===
check_for_updates() {
    if [[ "$CHECK_FOR_UPDATES" == "true" ]]; then
        echo "🔍 Checking for updates..."
        
        # Get latest release from GitHub API
        LATEST_VERSION=$(curl -s https://api.github.com/repos/PeerHoffmann/transcribe_openai_whisper/releases/latest | jq -r '.tag_name' 2>/dev/null)
        CURRENT_VERSION="1.1.2"
        
        if [[ "$LATEST_VERSION" != "null" ]] && [[ "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
            echo ""
            echo "🆕 UPDATE AVAILABLE!"
            echo "   Current version: $CURRENT_VERSION"
            echo "   Latest version:  $LATEST_VERSION"
            echo ""
            echo "📥 Update options:"
            echo "   1. git pull origin master (if cloned)"
            echo "   2. Download from: https://github.com/PeerHoffmann/transcribe_openai_whisper/releases/latest"
            echo ""
            
            while true; do
                read -p "❓ Do you want to continue with current version or update first? [c/u/q]: " choice
                case $choice in
                    [Cc]* ) 
                        echo "✅ Continuing with current version..."
                        echo ""
                        break
                        ;;
                    [Uu]* ) 
                        echo "🔄 Please update manually and restart the script."
                        echo ""
                        echo "If you cloned the repository:"
                        echo "   git pull origin master"
                        echo ""
                        echo "If you downloaded the script only:"
                        echo "   wget https://raw.githubusercontent.com/PeerHoffmann/transcribe_openai_whisper/master/transcribe_openai_whisper.sh -O transcribe_openai_whisper.sh"
                        echo "   chmod +x transcribe_openai_whisper.sh"
                        echo ""
                        exit 0
                        ;;
                    [Qq]* ) 
                        echo "👋 Exiting..."
                        exit 0
                        ;;
                    * ) 
                        echo "Please answer 'c' (continue), 'u' (update), or 'q' (quit)."
                        ;;
                esac
            done
        fi
    fi
}

# === DO NOT CHANGE ANYTHING BELOW THIS LINE ===
# Timeout configuration will be handled in the whisper command directly

# Create log file
LOG_FILE="$OUTPUT_DIR/transcription_log.txt"
SUMMARY_FILE="$OUTPUT_DIR/transcription_summary.txt"

# Check for updates
check_for_updates

echo "🎵 Whisper Audio Transcription started"
echo "Audio files from: $AUDIO_DIR"
echo "Output to: $OUTPUT_DIR"
echo "⚙️  Optimized for videos with music intros"
echo "🤖 Model: $WHISPER_MODEL"
echo "⏱️  Timeout: $([ "$ENABLE_TIMEOUT" == "true" ] && echo "${TIMEOUT_SECONDS}s" || echo "disabled")"
echo "Log file: $LOG_FILE"
echo "=================================="

# Create directories
mkdir -p "$OUTPUT_DIR"

# Initialize log file
cat > "$LOG_FILE" << EOF
WHISPER TRANSCRIPTION LOG
========================
Start: $(date)
Audio directory: $AUDIO_DIR
Output directory: $OUTPUT_DIR
Brand names: jonastone, stonenaturelle
Optimized for: Videos with music intros

EOF

# Activate Whisper environment
source ~/whisper-env/bin/activate

# Counters for statistics
total_audios=$(ls "$AUDIO_DIR"/*.{m4a,mp3,wav,M4A,MP3,WAV,mp4,avi,mkv,mov} 2>/dev/null | wc -l)
current=0
success_count=0
low_word_count=0
error_count=0

echo "📊 Found Audio/Video files: $total_audios"
echo ""

# Arrays for statistics
declare -a low_word_files
declare -a error_files
declare -a good_files

# Process all audio/video files
for audio in "$AUDIO_DIR"/*.{m4a,mp3,wav,M4A,MP3,WAV,mp4,avi,mkv,mov}; do
    if [[ -f "$audio" ]]; then
        current=$((current + 1))
        filename=$(basename "$audio")
        base_name=$(basename "$audio" | cut -d. -f1)
        
        echo "🎵 [$current/$total_audios] Processing: $filename"
        echo "[$current/$total_audios] START: $filename" >> "$LOG_FILE"
        
        start_time=$(date)
        echo "⏳ Processing running (may take time with long music intros)..."
        
        # Whisper with extended parameters for better music/speech separation
        if [[ "$ENABLE_TIMEOUT" == "true" ]]; then
            timeout "$TIMEOUT_SECONDS" whisper "$audio" \
                --model "$WHISPER_MODEL" \
                --output_dir "$OUTPUT_DIR" \
                --output_format txt \
                --initial_prompt "$BRAND_PROMPT" \
                --condition_on_previous_text "$CONDITION_ON_PREVIOUS_TEXT" \
                --no_speech_threshold "$NO_SPEECH_THRESHOLD" \
                --logprob_threshold "$LOGPROB_THRESHOLD" \
                --compression_ratio_threshold "$COMPRESSION_RATIO_THRESHOLD" \
                --verbose "$VERBOSE" >> "$LOG_FILE" 2>&1
        else
            whisper "$audio" \
                --model "$WHISPER_MODEL" \
                --output_dir "$OUTPUT_DIR" \
                --output_format txt \
                --initial_prompt "$BRAND_PROMPT" \
                --condition_on_previous_text "$CONDITION_ON_PREVIOUS_TEXT" \
                --no_speech_threshold "$NO_SPEECH_THRESHOLD" \
                --logprob_threshold "$LOGPROB_THRESHOLD" \
                --compression_ratio_threshold "$COMPRESSION_RATIO_THRESHOLD" \
                --verbose "$VERBOSE" >> "$LOG_FILE" 2>&1
        fi
        
        if [[ $? -eq 0 ]]; then
            
            # Check if transcript was created
            transcript_file="$OUTPUT_DIR/$base_name.txt"
            if [[ -f "$transcript_file" ]]; then
                # Count words and characters
                word_count=$(wc -w < "$transcript_file" 2>/dev/null || echo "0")
                char_count=$(wc -c < "$transcript_file" 2>/dev/null || echo "0")
                end_time=$(date)
                
                # Analyze transcript content
                content=$(cat "$transcript_file" 2>/dev/null)
                
                # Better evaluation for music intros
                if [[ $word_count -lt 3 ]] || [[ $char_count -lt 10 ]]; then
                    echo "⚠️  Very little text: $filename ($word_count words) - probably only music"
                    echo "LITTLE TEXT: $filename - $word_count words, $char_count characters" >> "$LOG_FILE"
                    low_word_files+=("$filename ($word_count words)")
                    ((low_word_count++))
                elif [[ $word_count -lt 10 ]]; then
                    echo "⚠️  Short text: $filename ($word_count words) - possibly mostly music"
                    echo "SHORT: $filename - $word_count words detected" >> "$LOG_FILE"
                    low_word_files+=("$filename ($word_count words - short)")
                    ((low_word_count++))
                else
                    echo "✅ Speech detected: $filename ($word_count words)"
                    echo "SUCCESS: $filename - $word_count words detected" >> "$LOG_FILE"
                    good_files+=("$filename ($word_count words)")
                    ((success_count++))
                fi
                
                # First 100 characters of transcript to log
                echo "Content (beginning): ${content:0:100}..." >> "$LOG_FILE"
                echo "Time: $start_time to $end_time" >> "$LOG_FILE"
            else
                echo "❌ Error: No transcription created for $filename"
                echo "ERROR: $filename - No output file created" >> "$LOG_FILE"
                error_files+=("$filename")
                ((error_count++))
            fi
        else
            if [[ "$ENABLE_TIMEOUT" == "true" ]]; then
                echo "❌ Timeout (${TIMEOUT_SECONDS}s) or error with $filename"
                echo "ERROR: $filename - Timeout or processing error" >> "$LOG_FILE"
                error_files+=("$filename (Timeout)")
            else
                echo "❌ Error with $filename"
                echo "ERROR: $filename - Processing error" >> "$LOG_FILE"
                error_files+=("$filename (Error)")
            fi
            ((error_count++))
        fi
        
        echo "--------------------------------" >> "$LOG_FILE"
        echo "--------------------------------"
    fi
done

# Create extended summary
cat > "$SUMMARY_FILE" << EOF
WHISPER TRANSCRIPTION SUMMARY
=============================
Date: $(date)
Total files: $total_audios
✅ With speech: $success_count
⚠️  Little text: $low_word_count
❌ Errors: $error_count

FILES WITH DETECTED SPEECH:
EOF

if [[ ${#good_files[@]} -gt 0 ]]; then
    for file in "${good_files[@]}"; do
        echo "✅ $file" >> "$SUMMARY_FILE"
    done
else
    echo "- None" >> "$SUMMARY_FILE"
fi

echo "" >> "$SUMMARY_FILE"
echo "FILES WITH LITTLE/NO TEXT (probably only music):" >> "$SUMMARY_FILE"

if [[ ${#low_word_files[@]} -gt 0 ]]; then
    for file in "${low_word_files[@]}"; do
        echo "⚠️  $file" >> "$SUMMARY_FILE"
    done
else
    echo "- None" >> "$SUMMARY_FILE"
fi

echo "" >> "$SUMMARY_FILE"
echo "ERROR FILES:" >> "$SUMMARY_FILE"

if [[ ${#error_files[@]} -gt 0 ]]; then
    for file in "${error_files[@]}"; do
        echo "❌ $file" >> "$SUMMARY_FILE"
    done
else
    echo "- None" >> "$SUMMARY_FILE"
fi

# Also write to main log
cat "$SUMMARY_FILE" >> "$LOG_FILE"

echo ""
echo "🎉 ALL FILES PROCESSED!"
echo "Transcripts saved in: $OUTPUT_DIR"
echo "📋 Detailed log: $LOG_FILE"
echo "📊 Summary: $SUMMARY_FILE"
echo ""
echo "📈 FINAL STATISTICS:"
echo "   ✅ With speech: $success_count"
echo "   ⚠️  Little text: $low_word_count" 
echo "   ❌ Errors: $error_count"

# Display summary
echo ""
echo "📋 RESULTS OVERVIEW:"
cat "$SUMMARY_FILE"