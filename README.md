[![Donate](https://img.shields.io/badge/Donate-PayPal-blue)](https://www.paypal.me/peerhoffmann)

If you find this project helpful, consider supporting me with a small donation:

# OpenAI Whisper Audio Transcription Script

A powerful Bash script for batch transcribing audio and video files using OpenAI's Whisper AI model. Optimized for handling media files with music intros and provides comprehensive logging and statistics.

## Features

- **Batch Processing**: Automatically processes all audio/video files in a directory
- **Multiple Formats**: Supports M4A, MP3, WAV, MP4, AVI, MKV, MOV files
- **Music Optimization**: Specifically tuned for files with musical introductions
- **Brand Recognition**: Enhanced transcription accuracy for specific brand names
- **Comprehensive Logging**: Detailed logs and statistics for each transcription
- **Timeout Protection**: Prevents hanging on problematic files (10-minute timeout)
- **Smart Analysis**: Categorizes results by speech content quality

## Prerequisites

### System Requirements
- **Operating System**: Linux (tested on WSL2)
- **Python**: 3.7 or higher
- **Disk Space**: Minimum 5GB free space for Whisper models
- **Memory**: 8GB RAM recommended for large model

### Dependencies
- **[OpenAI Whisper](https://github.com/openai/whisper)** - AI transcription model
- **[FFmpeg](https://ffmpeg.org/)** - Audio/video processing
- **Python Virtual Environment** - For isolated dependency management
- **Bash**: Version 4.0 or higher

## Installation

### Step 1: Install System Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv ffmpeg
```

**CentOS/RHEL:**
```bash
sudo yum install python3 python3-pip ffmpeg
```

### Step 2: Create Python Virtual Environment
```bash
python3 -m venv ~/whisper-env
source ~/whisper-env/bin/activate
```

### Step 3: Install Whisper
```bash
pip install -U openai-whisper
```

### Step 4: Download the Script
```bash
wget enter_your_github_raw_url_here/transcribe_openai_whisper.sh
chmod +x transcribe_openai_whisper.sh
```

### Step 5: Configure Paths
Edit the script and update these variables:
```bash
AUDIO_DIR="enter_your_audio_directory_here"
OUTPUT_DIR="enter_your_output_directory_here"
```

### Verification
Test the installation:
```bash
source ~/whisper-env/bin/activate
whisper --help
```

## Configuration

### Environment Setup
The script requires configuration of the following paths:

```bash
# Audio input directory
AUDIO_DIR="/path/to/your/audio/files"

# Transcription output directory  
OUTPUT_DIR="/path/to/your/transcripts"

# Brand names for enhanced recognition (optional)
BRAND_PROMPT="In this recording, the following brand names are mentioned: your_brand_1, your_brand_2"
```

### Whisper Model Configuration
The script uses the `large` model by default for best accuracy. Available models:
- `tiny` - Fastest, least accurate
- `base` - Balanced speed/accuracy
- `small` - Good accuracy, moderate time
- `medium` - Better accuracy, slower
- `large` - Best accuracy, slowest (default)

### Advanced Parameters
Current optimization settings:
- `no_speech_threshold: 0.6` - Sensitivity for detecting speech vs music
- `logprob_threshold: -1.0` - Confidence threshold for transcription
- `compression_ratio_threshold: 2.4` - Repetition detection
- `condition_on_previous_text: True` - Context awareness

## Usage

### Basic Usage
```bash
./transcribe_openai_whisper.sh
```

### Step-by-Step Process
1. **Activate Environment**: Script automatically activates the Whisper virtual environment
2. **File Discovery**: Scans the audio directory for supported file formats
3. **Processing**: Transcribes each file with progress indicators
4. **Analysis**: Categorizes results based on speech content quality
5. **Reporting**: Generates detailed logs and summary statistics

### Output Files
- **Individual Transcripts**: `filename.txt` for each processed file
- **Detailed Log**: `transcription_log.txt` with complete processing details
- **Summary Report**: `transcription_summary.txt` with statistics and categorized results

### Result Categories
- **✅ With Speech**: Files with substantial speech content (>10 words)
- **⚠️ Limited Text**: Files with minimal speech (3-10 words, likely mostly music)
- **❌ Errors**: Files that failed to process or generated no output

### Example Output
```
🎵 Whisper Audio Transcription started
Audio files from: /path/to/audio
Output to: /path/to/transcripts
⚙️ Optimized for videos with music intros
==================================
📊 Found Audio/Video files: 5

🎵 [1/5] Processing: example.mp3
⏳ Processing running (may take time with long music intros)...
✅ Speech detected: example.mp3 (127 words)

🎉 ALL FILES PROCESSED!
📈 FINAL STATISTICS:
   ✅ With Speech: 3
   ⚠️ Limited Text: 1
   ❌ Errors: 1
```

### Troubleshooting

**Common Issues:**

1. **Virtual Environment Not Found**
   ```bash
   # Recreate the environment
   python3 -m venv ~/whisper-env
   source ~/whisper-env/bin/activate
   pip install -U openai-whisper
   ```

2. **FFmpeg Not Found**
   ```bash
   sudo apt install ffmpeg  # Ubuntu/Debian
   sudo yum install ffmpeg  # CentOS/RHEL
   ```

3. **Permission Denied**
   ```bash
   chmod +x transcribe_openai_whisper.sh
   ```

4. **Out of Memory**
   - Use a smaller Whisper model (medium, small, base, tiny)
   - Process fewer files at once
   - Increase system swap space

5. **Files Not Processing**
   - Check file permissions in audio directory
   - Verify supported file formats
   - Check available disk space

## Tools & Dependencies

### Core Dependencies
- **[OpenAI Whisper](https://openai.com/research/whisper)** - AI speech recognition | [GitHub](https://github.com/openai/whisper) | [Docs](https://github.com/openai/whisper#setup)
- **[FFmpeg](https://ffmpeg.org/)** - Multimedia processing framework | [GitHub](https://github.com/FFmpeg/FFmpeg) | [Docs](https://ffmpeg.org/documentation.html)
- **[Python](https://python.org/)** - Programming language runtime | [GitHub](https://github.com/python/cpython) | [Docs](https://docs.python.org/3/)

### System Tools
- **[Bash](https://www.gnu.org/software/bash/)** - Unix shell and command language | [Docs](https://www.gnu.org/software/bash/manual/)
- **[GNU Coreutils](https://www.gnu.org/software/coreutils/)** - Basic file, shell and text manipulation utilities

### Development Tools
- **[Virtual Environment](https://docs.python.org/3/library/venv.html)** - Isolated Python environments | [Docs](https://docs.python.org/3/tutorial/venv.html)

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Follow** the existing code style and conventions
4. **Test** your changes thoroughly
5. **Update** documentation as needed
6. **Commit** your changes (`git commit -m 'Add amazing feature'`)
7. **Push** to the branch (`git push origin feature/amazing-feature`)
8. **Create** a Pull Request

### Coding Standards
- Use clear, descriptive variable names
- Add comments for complex logic
- Follow Bash best practices for error handling
- Test with various audio file types and sizes

---
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue)](https://www.paypal.me/peerhoffmann)

If you find this project helpful, consider supporting me with a small donation:

More information about me and my projects can be found at https://www.peer-hoffmann.de.

If you need support with search engine optimization for your website, online shop, or international project, feel free to contact me at https://www.om96.de.