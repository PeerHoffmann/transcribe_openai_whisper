# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial comprehensive documentation suite
- README.md with detailed installation and usage instructions
- CHANGELOG.md following Keep a Changelog format
- TODO.md with structured task management system
- CLAUDE.md with project context and development guidelines
- GitHub repository links to installation instructions

### Changed
- Project documentation language standardized to English
- Improved code organization and structure documentation
- Installation instructions now include git clone as recommended method with wget as alternative

## [1.0.0] - 2025-06-19

### Added
- Initial release of OpenAI Whisper transcription script
- Batch processing for multiple audio/video formats (M4A, MP3, WAV, MP4, AVI, MKV, MOV)
- Music intro optimization with specialized Whisper parameters
- Brand name recognition enhancement for improved transcription accuracy
- Comprehensive logging system with detailed processing statistics
- Smart categorization of transcription results based on speech content
- Timeout protection (10-minute limit per file) to prevent hanging
- Summary report generation with categorized results
- Support for large Whisper model for maximum accuracy
- Automatic virtual environment activation
- Progress indicators and real-time status updates

### Technical Details
- Whisper model: large (for best accuracy)
- No speech threshold: 0.6 (optimized for music detection)
- Log probability threshold: -1.0
- Compression ratio threshold: 2.4 (repetition detection)
- Context awareness enabled with previous text conditioning
- File processing timeout: 600 seconds (10 minutes)

### Features
- ✅ High-quality speech recognition for content-rich audio
- ⚠️ Smart detection of music-only or minimal speech content  
- ❌ Error handling and reporting for problematic files
- 📊 Detailed statistics and processing summaries
- 📋 Comprehensive logging for debugging and analysis
- 🎵 Optimized processing for media with musical introductions