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

**Important:** The first run will automatically download the selected Whisper model. Model sizes and capabilities:

| Model | Size | Languages | Download Time | Use Case |
|-------|------|-----------|---------------|----------|
| `tiny` | ~39 MB | English only | < 1 minute | Fast processing, English only |
| `base` | ~74 MB | English only | < 1 minute | Balanced speed/accuracy, English only |
| `small` | ~244 MB | Multilingual (99 languages) | 2-3 minutes | Good accuracy, supports all languages |
| `medium` | ~769 MB | Multilingual (99 languages) | 5-8 minutes | Better accuracy, supports all languages |
| `large` | ~1550 MB | Multilingual (99 languages) | 10-15 minutes | Best accuracy, supports all languages (default) |

**Supported Languages** (small, medium, large models):
Afrikaans, Albanian, Amharic, Arabic, Armenian, Assamese, Azerbaijani, Bashkir, Basque, Belarusian, Bengali, Bosnian, Breton, Bulgarian, Burmese, Castilian, Catalan, Chinese, Croatian, Czech, Danish, Dutch, English, Estonian, Faroese, Finnish, Flemish, French, Galician, Georgian, German, Greek, Gujarati, Haitian, Haitian Creole, Hausa, Hawaiian, Hebrew, Hindi, Hungarian, Icelandic, Indonesian, Italian, Japanese, Javanese, Kannada, Kazakh, Khmer, Korean, Lao, Latin, Latvian, Lingala, Lithuanian, Luxembourgish, Macedonian, Malagasy, Malay, Malayalam, Maltese, Maori, Marathi, Mongolian, Myanmar, Nepali, Norwegian, Nynorsk, Occitan, Pashto, Persian, Polish, Portuguese, Punjabi, Romanian, Russian, Sanskrit, Serbian, Shona, Sindhi, Sinhala, Slovak, Slovenian, Somali, Spanish, Sundanese, Swahili, Swedish, Tagalog, Tajik, Tamil, Tatar, Telugu, Thai, Tibetan, Turkish, Turkmen, Ukrainian, Urdu, Uzbek, Vietnamese, Welsh, Yiddish, Yoruba

Consider downloading the model before your first batch run:
```bash
# Test download with a small file to cache the model
echo "This is a test" | whisper --model large --language en -
```

### Step 4: Get the Script

**Option A: Clone the Repository (Recommended)**
```bash
git clone https://github.com/PeerHoffmann/transcribe_openai_whisper.git
cd transcribe_openai_whisper
chmod +x transcribe_openai_whisper.sh
```

**Option B: Download Script Only**
```bash
wget https://raw.githubusercontent.com/PeerHoffmann/transcribe_openai_whisper/master/transcribe_openai_whisper.sh
chmod +x transcribe_openai_whisper.sh
```

### Step 5: Configure Settings
Edit the `config.json` file with your settings:
```json
{
  "audio_dir": "/path/to/your/audio/files",
  "output_dir": "/path/to/your/transcripts",
  "whisper_model": "large",
  "brand_prompt": "Optional: brand names for better recognition",
  "check_for_updates": true,
  "advanced_settings": {
    "timeout_seconds": 600,
    "enable_timeout": true
  }
}
```

**Note:** The script requires `jq` for JSON parsing:
```bash
sudo apt install jq  # Ubuntu/Debian
brew install jq      # macOS
```

### Verification
Test the installation:
```bash
source ~/whisper-env/bin/activate
whisper --help
```

## Configuration

### JSON Configuration File
All settings are configured in `config.json`. Key settings include:

```json
{
  "audio_dir": "/path/to/your/audio/files",
  "output_dir": "/path/to/your/transcripts", 
  "whisper_model": "large",
  "brand_prompt": "In this recording, the following brand names are mentioned: your_brand_1, your_brand_2",
  "check_for_updates": true,
  "advanced_settings": {
    "no_speech_threshold": 0.6,
    "logprob_threshold": -1.0,
    "compression_ratio_threshold": 2.4,
    "condition_on_previous_text": true,
    "timeout_seconds": 600,
    "enable_timeout": true,
    "verbose": true
  }
}
```

### Timeout Configuration
- **enable_timeout**: `true` - Enable timeout per file, `false` - No timeout (process all files completely)
- **timeout_seconds**: Duration in seconds when timeout is enabled (default: 600 = 10 minutes)

### Whisper Model Configuration
The script uses the `large` model by default for best accuracy. To change the model, edit the `whisper_model` setting in `config.json`:

**Model Selection Guide:**
- `tiny` - Fastest processing, English only, lowest accuracy
- `base` - Fast processing, English only, basic accuracy  
- `small` - Good accuracy, multilingual (99 languages), moderate speed
- `medium` - Better accuracy, multilingual (99 languages), slower
- `large` - Best accuracy, multilingual (99 languages), slowest (default)

**Recommendation:** Use `large` for best results, `medium` for good balance of speed/accuracy, or `small` if storage/bandwidth is limited.

## Updating

### Automatic Update Checking
The script automatically checks for updates when `check_for_updates` is set to `true` in `config.json`. It will display a notification if a newer version is available.

### Manual Update Methods

**If you cloned the repository:**
```bash
git pull origin master
```

**If you downloaded the script only:**
```bash
# Download the latest version
wget https://raw.githubusercontent.com/PeerHoffmann/transcribe_openai_whisper/master/transcribe_openai_whisper.sh -O transcribe_openai_whisper.sh
chmod +x transcribe_openai_whisper.sh
```

**Check current version:**
The version is displayed in the script header and when checking for updates.

**Latest releases:**
Visit https://github.com/PeerHoffmann/transcribe_openai_whisper/releases for the latest version information.

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