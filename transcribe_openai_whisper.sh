#!/bin/bash

# OpenAI Whisper Transcription Script
# Version: 1.4.0
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
OUTPUT_FORMATS=$(jq -r '.output_formats[]' "$CONFIG_FILE" | tr '\n' ',' | sed 's/,$//')
CHECK_FOR_UPDATES=$(jq -r '.check_for_updates' "$CONFIG_FILE")

# Load OpenAI API configuration
OPENAI_API_ENABLED=$(jq -r '.openai_api.enabled' "$CONFIG_FILE")
OPENAI_API_KEY=$(jq -r '.openai_api.api_key' "$CONFIG_FILE")
OPENAI_API_MODEL=$(jq -r '.openai_api.model' "$CONFIG_FILE")
OPENAI_API_ORG=$(jq -r '.openai_api.organization' "$CONFIG_FILE")
OPENAI_API_BASE_URL=$(jq -r '.openai_api.base_url' "$CONFIG_FILE")

# Load advanced settings
NO_SPEECH_THRESHOLD=$(jq -r '.advanced_settings.no_speech_threshold' "$CONFIG_FILE")
LOGPROB_THRESHOLD=$(jq -r '.advanced_settings.logprob_threshold' "$CONFIG_FILE")
COMPRESSION_RATIO_THRESHOLD=$(jq -r '.advanced_settings.compression_ratio_threshold' "$CONFIG_FILE")
CONDITION_ON_PREVIOUS_TEXT_RAW=$(jq -r '.advanced_settings.condition_on_previous_text' "$CONFIG_FILE")
TIMEOUT_SECONDS=$(jq -r '.advanced_settings.timeout_seconds' "$CONFIG_FILE")
ENABLE_TIMEOUT=$(jq -r '.advanced_settings.enable_timeout' "$CONFIG_FILE")
VERBOSE_RAW=$(jq -r '.advanced_settings.verbose' "$CONFIG_FILE")

# Convert JSON booleans to Whisper format (True/False)
if [[ "$CONDITION_ON_PREVIOUS_TEXT_RAW" == "true" ]]; then
    CONDITION_ON_PREVIOUS_TEXT="True"
else
    CONDITION_ON_PREVIOUS_TEXT="False"
fi

if [[ "$VERBOSE_RAW" == "true" ]]; then
    VERBOSE="True"
else
    VERBOSE="False"
fi

# Validate required configuration
if [[ "$AUDIO_DIR" == "enter_your_audio_directory_here" ]] || [[ "$OUTPUT_DIR" == "enter_your_output_directory_here" ]]; then
    echo "❌ Error: Please configure your audio_dir and output_dir in config.json"
    exit 1
fi

# Validate output formats
if [[ -z "$OUTPUT_FORMATS" ]]; then
    echo "❌ Error: No output formats specified in config.json"
    echo "   Please add output_formats array with at least one format: txt, json, srt, tsv, vtt"
    exit 1
fi

# Validate OpenAI API configuration if enabled
if [[ "$OPENAI_API_ENABLED" == "true" ]]; then
    if [[ "$OPENAI_API_KEY" == "enter_your_openai_api_key_here" ]] || [[ -z "$OPENAI_API_KEY" ]]; then
        echo "❌ Error: OpenAI API is enabled but no valid API key provided in config.json"
        echo "   Please set your API key in config.json or disable API mode"
        echo "   Get your API key from: https://platform.openai.com/api-keys"
        exit 1
    fi
    
    # Check if curl is available for API calls
    if ! command -v curl &> /dev/null; then
        echo "❌ Error: curl is required for OpenAI API but not installed"
        echo "   Please install curl: sudo apt install curl"
        exit 1
    fi
fi

# === UPDATE CHECKING ===
check_for_updates() {
    if [[ "$CHECK_FOR_UPDATES" == "true" ]]; then
        echo "🔍 Checking for updates..."
        
        # Check if curl is available
        if ! command -v curl &> /dev/null; then
            echo "⚠️  curl not installed - skipping update check"
            echo "   To enable update checking: sudo apt install curl"
            echo ""
            return
        fi
        
        # Get latest release from GitHub API
        LATEST_VERSION=$(curl -s https://api.github.com/repos/PeerHoffmann/transcribe_openai_whisper/releases/latest | jq -r '.tag_name' 2>/dev/null)
        CURRENT_VERSION="1.4.0"
        
        if [[ "$LATEST_VERSION" != "null" ]] && [[ "$LATEST_VERSION" != "" ]] && [[ "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
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

# === OPENAI API FUNCTIONS ===
transcribe_with_api() {
    local audio_file="$1"
    local base_name="$2"
    
    echo "🔗 Using OpenAI API for transcription..."
    
    # Convert OUTPUT_FORMATS to array
    IFS=',' read -ra FORMATS_ARRAY <<< "$OUTPUT_FORMATS"
    
    # Process each requested format
    for format in "${FORMATS_ARRAY[@]}"; do
        local output_file="$OUTPUT_DIR/$base_name.$format"
        
        # Prepare API request
        local curl_cmd="curl -s -X POST \"$OPENAI_API_BASE_URL/audio/transcriptions\""
        curl_cmd="$curl_cmd -H \"Authorization: Bearer $OPENAI_API_KEY\""
        curl_cmd="$curl_cmd -H \"Content-Type: multipart/form-data\""
        curl_cmd="$curl_cmd -F \"file=@$audio_file\""
        curl_cmd="$curl_cmd -F \"model=$OPENAI_API_MODEL\""
        
        # Set response format based on requested format
        case "$format" in
            "txt") curl_cmd="$curl_cmd -F \"response_format=text\"" ;;
            "json") curl_cmd="$curl_cmd -F \"response_format=verbose_json\"" ;;
            "srt") curl_cmd="$curl_cmd -F \"response_format=srt\"" ;;
            "vtt") curl_cmd="$curl_cmd -F \"response_format=vtt\"" ;;
            "tsv") curl_cmd="$curl_cmd -F \"response_format=text\"" ;; # TSV not supported by API, use text
        esac
        
        # Add organization if specified
        if [[ -n "$OPENAI_API_ORG" ]] && [[ "$OPENAI_API_ORG" != "" ]]; then
            curl_cmd="$curl_cmd -H \"OpenAI-Organization: $OPENAI_API_ORG\""
        fi
        
        # Add initial prompt if specified
        if [[ -n "$BRAND_PROMPT" ]] && [[ "$BRAND_PROMPT" != "" ]]; then
            curl_cmd="$curl_cmd -F \"prompt=$BRAND_PROMPT\""
        fi
        
        # Execute API call with timeout
        local api_response
        if [[ "$ENABLE_TIMEOUT" == "true" ]]; then
            api_response=$(timeout "$TIMEOUT_SECONDS" bash -c "$curl_cmd" 2>&1)
            local exit_code=$?
        else
            api_response=$(bash -c "$curl_cmd" 2>&1)
            local exit_code=$?
        fi
        
        # Check for timeout
        if [[ $exit_code -eq 124 ]]; then
            echo "❌ API request timed out after ${TIMEOUT_SECONDS}s for format $format"
            return 1
        fi
        
        # Check for curl errors
        if [[ $exit_code -ne 0 ]]; then
            echo "❌ API request failed with exit code $exit_code for format $format"
            echo "Response: $api_response" >> "$LOG_FILE"
            return 1
        fi
        
        # Check if response contains an error
        if echo "$api_response" | grep -q '"error"'; then
            echo "❌ API returned an error for format $format:"
            echo "$api_response" | jq -r '.error.message' 2>/dev/null || echo "$api_response"
            echo "API Error ($format): $api_response" >> "$LOG_FILE"
            return 1
        fi
        
        # Save transcription to output file
        echo "$api_response" > "$output_file"
        echo "✅ Created $format file: $(basename "$output_file")"
    done
    
    return 0
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
echo "🤖 Mode: $([ "$OPENAI_API_ENABLED" == "true" ] && echo "OpenAI API ($OPENAI_API_MODEL)" || echo "Local Whisper ($WHISPER_MODEL)")"
echo "📄 Output formats: $OUTPUT_FORMATS"
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
        # Check if any transcript already exists (resume functionality) - check for any format
        transcript_file="$OUTPUT_DIR/$base_name.txt"  # Use txt for word counting (most reliable)
        
        # Check if any of the requested formats already exist
        skip_file=false
        IFS=',' read -ra FORMATS_ARRAY <<< "$OUTPUT_FORMATS"
        for format in "${FORMATS_ARRAY[@]}"; do
            if [[ -f "$OUTPUT_DIR/$base_name.$format" ]]; then
                skip_file=true
                break
            fi
        done
        
        if [[ "$skip_file" == "true" ]]; then
            echo "⏭️  [$current/$total_audios] Skipping: $filename (already processed)"
            echo "[$current/$total_audios] SKIPPED: $filename - transcript already exists" >> "$LOG_FILE"
            
            # Count existing transcript for statistics (use txt if available, otherwise first available format)
            word_count_file="$transcript_file"
            if [[ ! -f "$word_count_file" ]]; then
                # Find first available format for word counting
                for format in "${FORMATS_ARRAY[@]}"; do
                    if [[ -f "$OUTPUT_DIR/$base_name.$format" ]]; then
                        word_count_file="$OUTPUT_DIR/$base_name.$format"
                        break
                    fi
                done
            fi
            
            existing_word_count=$(wc -w < "$word_count_file" 2>/dev/null || echo "0")
            if [[ $existing_word_count -lt 3 ]]; then
                low_word_files+=("$filename ($existing_word_count words - existing)")
                ((low_word_count++))
            elif [[ $existing_word_count -lt 10 ]]; then
                low_word_files+=("$filename ($existing_word_count words - existing, short)")
                ((low_word_count++))
            else
                good_files+=("$filename ($existing_word_count words - existing)")
                ((success_count++))
            fi
            continue
        fi
        
        echo "🎵 [$current/$total_audios] Processing: $filename"
        echo "[$current/$total_audios] START: $filename" >> "$LOG_FILE"
        
        start_time=$(date)
        echo "⏳ Processing running (may take time with long music intros)..."
        
        # Choose transcription method based on configuration
        if [[ "$OPENAI_API_ENABLED" == "true" ]]; then
            # Use OpenAI API for transcription
            transcribe_with_api "$audio" "$base_name"
            transcription_exit_code=$?
        else
            # Use local Whisper with extended parameters for better music/speech separation
            if [[ "$ENABLE_TIMEOUT" == "true" ]]; then
                timeout "$TIMEOUT_SECONDS" whisper "$audio" \
                    --model "$WHISPER_MODEL" \
                    --output_dir "$OUTPUT_DIR" \
                    --output_format "$OUTPUT_FORMATS" \
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
                    --output_format "$OUTPUT_FORMATS" \
                    --initial_prompt "$BRAND_PROMPT" \
                    --condition_on_previous_text "$CONDITION_ON_PREVIOUS_TEXT" \
                    --no_speech_threshold "$NO_SPEECH_THRESHOLD" \
                    --logprob_threshold "$LOGPROB_THRESHOLD" \
                    --compression_ratio_threshold "$COMPRESSION_RATIO_THRESHOLD" \
                    --verbose "$VERBOSE" >> "$LOG_FILE" 2>&1
            fi
            transcription_exit_code=$?
        fi
        
        if [[ $transcription_exit_code -eq 0 ]]; then
            
            # Check if any transcript was created (prefer txt for word counting)
            word_count_file="$transcript_file"
            if [[ ! -f "$word_count_file" ]]; then
                # Find first available format for word counting
                IFS=',' read -ra FORMATS_ARRAY <<< "$OUTPUT_FORMATS"
                for format in "${FORMATS_ARRAY[@]}"; do
                    if [[ -f "$OUTPUT_DIR/$base_name.$format" ]]; then
                        word_count_file="$OUTPUT_DIR/$base_name.$format"
                        break
                    fi
                done
            fi
            
            if [[ -f "$word_count_file" ]]; then
                # Count words and characters
                word_count=$(wc -w < "$word_count_file" 2>/dev/null || echo "0")
                char_count=$(wc -c < "$word_count_file" 2>/dev/null || echo "0")
                end_time=$(date)
                
                # Analyze transcript content
                content=$(cat "$word_count_file" 2>/dev/null)
                
                # Show created files
                echo "📄 Generated formats:"
                IFS=',' read -ra FORMATS_ARRAY <<< "$OUTPUT_FORMATS"
                for format in "${FORMATS_ARRAY[@]}"; do
                    if [[ -f "$OUTPUT_DIR/$base_name.$format" ]]; then
                        echo "   ✅ $base_name.$format"
                    fi
                done
                
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