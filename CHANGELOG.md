# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.0] - 2025-06-22

### Added
- **Resume Functionality**: Automatically skips files that already have transcript files when rerunning script
- Smart detection of existing transcripts with word count analysis for statistics
- Progress preservation across script interruptions and reruns
- Status indicators showing ⏭️ for skipped files vs 🎵 for new processing

### Changed
- Enhanced step-by-step process documentation to include resume check
- Added comprehensive resume functionality documentation in README

## [1.2.0] - 2025-06-22

### Added
- **OpenAI API Support**: Alternative processing mode using OpenAI's Whisper API for slower CPUs
- API configuration section in config.json with key, model, organization, and base URL settings
- Automatic API key validation and curl dependency checking when API mode is enabled
- API vs Local processing mode display in script output
- API transcription function with proper error handling and timeout support
- Comprehensive OpenAI API documentation in README including pricing, setup, and comparison table

### Changed
- Enhanced script output to show processing mode (Local Whisper vs OpenAI API)
- Updated README.md with detailed OpenAI API setup instructions and feature comparison
- Added dual processing mode feature to main features list

## [1.1.3] - 2025-06-22

### Fixed
- **CRITICAL**: Fixed boolean parameter handling for Whisper (convert JSON true/false to True/False)
- Fixed "invalid str2bool value: 'true'" error that prevented all files from processing
- Updated default configuration with proper paths and settings
- Fixed update checking when curl is not installed (graceful fallback with helpful message)
- Prevent false positive update prompts when curl command fails

## [1.1.2] - 2025-06-22

### Added
- Interactive update prompts - script now stops and asks user to continue or update when newer version available
- User choice options: continue (c), update (u), or quit (q)
- Clear update instructions for both git cloned and direct download installations

### Fixed
- Fixed bash syntax error in conditional whisper command structure
- Improved error handling for timeout vs non-timeout command execution

## [1.1.1] - 2025-06-22

### Fixed
- Fixed timeout handling when timeout is disabled (syntax error causing all files to fail)
- Proper conditional logic for timeout vs non-timeout whisper commands

## [1.1.0] - 2025-06-22

### Added
- JSON configuration file (config.json) for easy settings management
- Automatic update checking via GitHub API
- Configurable timeout option (can be disabled for complete processing)
- Model and language information with all 99 supported languages listed
- Update instructions and version checking
- Comprehensive installation guide with model download information
- jq dependency for JSON configuration parsing

### Changed
- Script completely translated from German to English
- Configuration moved from hardcoded variables to JSON file
- All Whisper parameters now configurable via config.json
- Installation instructions updated for JSON configuration
- README restructured with configuration, updating, and model selection guides
- Timeout system made optional and configurable

### Fixed
- Sanitized hardcoded file paths with placeholder values
- Improved error handling for missing configuration

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