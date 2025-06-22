# TODO

Comprehensive task management for the OpenAI Whisper Transcription Script project.

## 🔥 Urgent
*Critical bugs and blockers (complete within days)*


## ⚡ High Priority
*Important features and fixes (complete within weeks)*



- [ ] **Implement CLI argument parsing** - Add command-line options for common settings
  - **Status**: Not Started
  - **Assignee**: @peerhoffmann
  - **Estimate**: 4h
  - **Dependencies**: Configuration file support
  - **Labels**: feature, cli
  - **Created**: 2025-06-22
  - **Notes**: Users should be able to override config via CLI flags

## 📈 Medium Priority
*Enhancements and optimizations (complete within months)*

- [ ] **Add progress bar with ETA** - Show visual progress indicator with estimated completion time
  - **Status**: Not Started
  - **Assignee**: @peerhoffmann
  - **Estimate**: 3h
  - **Labels**: enhancement, ux
  - **Created**: 2025-06-22
  - **Notes**: Would improve user experience during long batch processes

- [ ] **Add resume functionality** - Skip already processed files when rerunning script
  - **Status**: Not Started
  - **Assignee**: @peerhoffmann
  - **Estimate**: 2h
  - **Labels**: feature, convenience
  - **Created**: 2025-06-22
  - **Notes**: Check for existing transcript files before processing

- [ ] **Create output format options** - Support JSON, SRT, VTT output formats
  - **Status**: Not Started
  - **Assignee**: @peerhoffmann
  - **Estimate**: 1d
  - **Labels**: feature, output
  - **Created**: 2025-06-22
  - **Notes**: Different formats useful for different applications

- [ ] **Add audio quality detection** - Analyze input quality and adjust Whisper settings accordingly
  - **Status**: Not Started
  - **Assignee**: @peerhoffmann
  - **Estimate**: 2d
  - **Labels**: enhancement, quality
  - **Created**: 2025-06-22
  - **Notes**: Could improve accuracy for low-quality recordings

## 💡 Ideas
*Brainstormed concepts for evaluation*


## Completed

### Recently Finished (move to CHANGELOG.md after 30 days)

- [x] **Create comprehensive README.md** - Detailed documentation with installation and usage
  - **Status**: Done
  - **Assignee**: @peerhoffmann
  - **Completed**: 2025-06-22
  - **Notes**: Includes donation badges, prerequisites, installation steps, configuration, usage examples

- [x] **Create CHANGELOG.md** - Version history following Keep a Changelog format
  - **Status**: Done
  - **Assignee**: @peerhoffmann
  - **Completed**: 2025-06-22
  - **Notes**: Documents initial release (v1.0.0) from 2025-06-19

- [x] **Translate German text to English in main script** - Convert all German comments, messages, and output to English
  - **Status**: Done
  - **Assignee**: @peerhoffmann
  - **Completed**: 2025-06-22
  - **Notes**: Completed in v1.1.0 - Full English translation implemented

- [x] **Add configuration file support** - Create config.json for settings instead of hardcoded variables
  - **Status**: Done
  - **Assignee**: @peerhoffmann
  - **Completed**: 2025-06-22
  - **Notes**: Completed in v1.1.0 - JSON configuration system with jq parsing

- [x] **OpenAI API integration** - Add cloud processing support as alternative to local Whisper
  - **Status**: Done
  - **Assignee**: @peerhoffmann
  - **Completed**: 2025-06-22
  - **Notes**: Completed in v1.2.0 - Full OpenAI API support with configuration validation

---

**Last Updated**: 2025-06-22  
**Total Tasks**: 8 (0 urgent, 1 high priority, 4 medium priority, 0 ideas)  
**Completed**: 6