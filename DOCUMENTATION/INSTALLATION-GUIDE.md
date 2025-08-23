# Sefirot Installation Guide

## Installation Methods

### Method 1: Electron GUI Installer (Recommended)

The professional Electron installer provides a complete guided experience with Sefirot Consulting branding:

```bash
cd SEFIROT-COMPLETE-INSTALLER
npm install
npm start
```

**Complete Installation Experience:**

#### **Phase 1: Welcome & System Check**
- Sefirot Consulting branded welcome screen with Tree of Life symbolism
- Feature overview with gold/charcoal visual design
- Automated system requirements validation (macOS 12.0+, 8GB+ RAM, 10GB+ storage)
- Hardware detection and optimization profiling for Intel/Apple Silicon

#### **Phase 2: Secure API Credential Collection**
- Clean interface for entering API keys with real-time validation
- Support for essential services (Anthropic Claude Pro, OpenAI) 
- Optional services (Shopify, RunPod, Paperspace, Pinecone)
- Secure encrypted storage using macOS keychain integration
- Service connectivity testing before proceeding

#### **Phase 3: Automated Platform Installation**
- 5 numbered installation steps with visual progress tracking
- Real-time progress rings showing completion percentage and ETA
- Detailed sub-step information for each phase
- Streaming console logs with syntax highlighting
- Automatic error detection and recovery mechanisms

#### **Phase 4: Interactive AI Butler Tour**
- Socratic learning experience with AI butler character
- 5 comprehensive sections covering platform capabilities
- Interactive code demonstrations and feature explanations
- Keyboard navigation (Space/Enter to advance, Esc to exit)
- Auto-advance with pause-on-hover functionality

#### **Phase 5: Production Platform Ready**
- Automatic Obsidian vault launch with Sefirot configuration
- CLI tools integration with Terminal shell
- Sample documents processed for immediate exploration
- Platform validation with built-in diagnostic tools

### Method 2: Command Line Installation

For advanced users or automated deployment:

```bash
# Run steps sequentially
./INSTALLATION/step_01_environment_setup.sh
./INSTALLATION/step_02_python_environment.sh
./INSTALLATION/step_03_chromadb_platform.sh
./INSTALLATION/step_04_obsidian_integration.sh
./INSTALLATION/step_05_final_configuration.sh
```

## System Requirements

- **macOS**: 12.0 (Monterey) or later
- **Memory**: 8GB+ recommended (4GB minimum)
- **Storage**: 10GB+ available space
- **Architecture**: Intel x64 or Apple Silicon (M1/M2/M3)

## Post-Installation Verification

### **Immediate Steps After GUI Installation**
1. **Terminal Integration**: New Terminal windows will have `sefirot` commands available
2. **System Validation**: Run `sefirot status` to verify all components
3. **API Testing**: Use `sefirot test-apis` to confirm credential setup
4. **Obsidian Vault**: SefirotVault opens automatically with sample content

### **First-Time Usage Workflow**
1. **Take the Butler Tour**: Complete the interactive guided tour to learn platform capabilities
2. **Explore Sample Documents**: Review pre-processed documents in Obsidian to understand structure
3. **Process Your Content**: Use `sefirot sync ~/Documents/` to add your own documents
4. **Query Intelligence**: Try `sefirot query "what documents discuss project planning?"` 
5. **Configure Privacy**: Adjust privacy tiers with `sefirot config privacy`

### **Verification Commands**
```bash
# Complete system health check
sefirot doctor

# Test individual components
sefirot test-chromadb
sefirot test-obsidian 
sefirot test-apis

# View configuration
sefirot config show

# Process sample documents
sefirot sync --sample-docs
```

### **Troubleshooting Installation Issues**
If installation fails:
1. **Check Logs**: View detailed logs in the GUI console window
2. **Manual Steps**: Run individual installation scripts from SEQUENCED-INSTALLATION/
3. **Common Issues**: Consult TROUBLESHOOTING.md for specific error solutions
4. **Clean Restart**: Use uninstaller and restart if needed