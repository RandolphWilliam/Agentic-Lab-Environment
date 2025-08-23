# Sefirot Intelligence Platform Installation Guide

**Complete automated setup process for Mac environments with professional Electron GUI installer and command-line alternatives.**

## Installation Overview

The Sefirot installation system provides two complete paths for deploying the privacy-first AI intelligence platform: a professional Electron GUI installer with real-time progress tracking, and a command-line installation system for advanced users. Both methods result in identical production-ready environments.

## System Requirements

### Minimum Requirements
- **macOS 12.0 Monterey or later** (Intel x64 or Apple Silicon M1/M2/M3)
- **8GB RAM minimum** (16GB+ recommended for large document processing)
- **10GB+ available storage** (additional space needed for document collections)
- **Python 3.11** (automatically installed via Conda)
- **Internet connection** for initial setup and API service configuration

### Recommended Configuration
- **macOS 13.0 Ventura or macOS 14.0 Sonoma**
- **16GB+ RAM** for optimal performance with large document collections
- **20GB+ SSD storage** with additional space for knowledge management
- **Apple Silicon M1/M2/M3 Mac** for enhanced AI processing performance

## Required API Credentials

Before beginning installation, obtain these API credentials:

### Essential Services (Required)
- **Anthropic Claude Pro**: API key from [console.anthropic.com](https://console.anthropic.com)
  - Format: `sk-ant-api03-...`
  - Used for: Primary AI processing and document analysis
  - Privacy impact: Processes Tier 1 and Tier 2 content with user consent

- **OpenAI API**: API key from [platform.openai.com](https://platform.openai.com/api-keys)  
  - Format: `sk-...`
  - Used for: Secondary AI processing and embedding generation
  - Privacy impact: Processes Tier 1 content, limited Tier 2 with explicit consent

### Optional Services (Enhanced Features)
- **Pinecone**: Vector database cloud backup and synchronization
- **RunPod**: GPU cloud acceleration for large model processing
- **Paperspace**: Alternative GPU platform for intensive AI workloads
- **Shopify**: E-commerce intelligence integration (if applicable)

## Installation Method 1: Professional Electron GUI (Recommended)

### Quick Start
```bash
# Navigate to installer directory
cd SEFIROT-COMPLETE-INSTALLER

# Install Node.js dependencies
npm install

# Launch professional installer
npm start
```

### Installation Phases

**Phase 1: Welcome and System Validation**
- Sefirot-branded welcome screen with platform overview
- Automated macOS version and hardware compatibility checking
- Available memory and storage space validation
- Python environment detection and preparation
- Pre-installation checklist with clear pass/fail indicators

**Phase 2: Secure API Credential Collection**
- Clean, professional UI for API key entry with real-time validation
- Secure credential storage using macOS keychain integration
- Service connectivity testing before proceeding
- Privacy tier explanation and configuration options

**Phase 3: Automated Platform Installation**
- Five sequential installation steps with visual progress tracking
- Real-time progress rings with ETA calculations
- Streaming console output with syntax highlighting
- Automatic error detection and recovery mechanisms
- Robust retry logic for network or dependency issues

**Phase 4: Knowledge Management Setup**  
- Automated Obsidian installation and vault configuration
- AI-enhanced template system deployment
- Sample document processing demonstration
- Knowledge graph initialization and testing

**Phase 5: Interactive Platform Tour**
- Socratic learning experience with AI guide
- Five educational modules covering platform capabilities
- Interactive demonstrations with live examples
- Keyboard navigation with auto-advance and pause controls

### GUI Installation Features

**Real-time Progress Monitoring**:
- Visual progress indicators for each installation step
- Detailed sub-step progress with estimated completion times
- Color-coded status indicators (pending, active, completed, error)
- Streaming log output with syntax highlighting and filtering

**Error Handling and Recovery**:
- Automatic detection of common installation issues
- Intelligent retry mechanisms with exponential backoff
- Clear error messages with suggested resolution steps
- Rollback capabilities for failed installation attempts

**Professional User Experience**:
- Native macOS design language with Sefirot branding
- Responsive interface optimized for various screen sizes
- Accessibility features including keyboard navigation
- Progress persistence across application restarts

## Installation Method 2: Command Line Installation

### Sequential Installation Scripts

Execute the installation steps in order, each script validates completion before proceeding:

```bash
# Step 1: Environment setup and system validation
./INSTALLATION/step_01_environment_setup.sh

# Step 2: Python environment with AI/ML packages  
./INSTALLATION/step_02_python_environment.sh

# Step 3: ChromaDB platform and intelligence engine
./INSTALLATION/step_03_chromadb_platform.sh

# Step 4: Obsidian integration and knowledge management
./INSTALLATION/step_04_obsidian_integration.sh

# Step 5: Final configuration, testing, and validation
./INSTALLATION/step_05_final_configuration.sh
```

### Step-by-Step Breakdown

**Step 1: Environment Setup** (`step_01_environment_setup.sh`)
- macOS version detection and compatibility validation
- Hardware profiling for optimal performance configuration
- Homebrew installation or validation
- Essential system tools installation (git, wget, curl)
- Directory structure creation for platform components

**Step 2: Python Environment** (`step_02_python_environment.sh`)
- Anaconda/Miniconda installation with Python 3.11
- Virtual environment creation with optimized package channels
- Core AI/ML library installation (numpy, scipy, pandas)
- ChromaDB, sentence-transformers, spaCy installation
- GPU acceleration libraries for Apple Silicon

**Step 3: ChromaDB Platform** (`step_03_chromadb_platform.sh`)
- ChromaDB service configuration and initialization
- Vector embedding model download and setup
- Database schema creation for document collections
- Privacy framework configuration and testing
- Intelligence engine deployment and validation

**Step 4: Obsidian Integration** (`step_04_obsidian_integration.sh`)
- Obsidian application installation via Homebrew Cask
- Vault creation with AI-enhanced template structure
- Community plugin installation and configuration
- Bi-directional linking setup with ChromaDB integration
- Knowledge graph initialization and testing

**Step 5: Final Configuration** (`step_05_final_configuration.sh`)
- API credential configuration and secure storage
- System service registration for background processing
- Performance optimization based on detected hardware
- Comprehensive platform testing and validation
- Sample document processing demonstration

### Command Line Installation Options

**Verbose Installation**:
```bash
# Enable detailed output for troubleshooting
./INSTALLATION/step_01_environment_setup.sh --verbose
```

**Custom Installation Paths**:
```bash
# Specify custom installation directory
./INSTALLATION/step_01_environment_setup.sh --install-dir /custom/path
```

**Resume Interrupted Installation**:
```bash
# Resume from specific step
./INSTALLATION/step_03_chromadb_platform.sh --resume-from checkpoint
```

## Post-Installation Configuration

### Credential Management Setup

```bash
# Configure API credentials securely
python CORE-PLATFORM/chromadb_intelligence_engine.py --configure-credentials

# Test API connectivity
python CORE-PLATFORM/chromadb_intelligence_engine.py --test-services
```

### Privacy Framework Configuration

```bash
# Configure privacy tiers and processing rules
python CORE-PLATFORM/chromadb_intelligence_engine.py --configure-privacy

# Test privacy classification
python CORE-PLATFORM/chromadb_intelligence_engine.py --test-classification
```

### Performance Optimization

```bash
# Run hardware-specific optimization
python CORE-PLATFORM/hardware_profiler.py --optimize-for-system

# Configure memory and processing limits
python CORE-PLATFORM/chromadb_intelligence_engine.py --configure-performance
```

## Validation and Testing

### Automated System Validation

```bash
# Complete system health check
python CORE-PLATFORM/chromadb_intelligence_engine.py --system-check

# Expected output:
# ChromaDB installation: PASSED
# Embedding models: PASSED  
# API services: PASSED
# Obsidian integration: PASSED
# Privacy framework: PASSED
# Performance optimization: PASSED
```

### Test Document Processing

```bash
# Process sample documents to verify functionality
python CORE-PLATFORM/chromadb_intelligence_engine.py \
  --test-processing \
  --sample-documents TEMPLATES/document-ingestion/samples/

# Test semantic search
python CORE-PLATFORM/chromadb_intelligence_engine.py \
  --test-search "artificial intelligence research"
```

## Troubleshooting Common Installation Issues

### Python Environment Issues

**Conda Installation Failures**:
```bash
# Clean conda installation
rm -rf ~/miniconda3
./INSTALLATION/step_02_python_environment.sh --clean-install
```

**Package Dependency Conflicts**:
```bash
# Reset environment with minimal packages
conda env remove -n sefirot-intelligence
./INSTALLATION/step_02_python_environment.sh --minimal-install
```

### ChromaDB Setup Problems

**Database Initialization Failures**:
```bash
# Reset ChromaDB with clean database
rm -rf ./chromadb-storage
python CORE-PLATFORM/chromadb_intelligence_engine.py --initialize-database
```

**Embedding Model Download Issues**:
```bash
# Manual embedding model installation
python -c "
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('all-MiniLM-L6-v2')
print('Embedding model installed successfully')
"
```

### API Credential Configuration

**Keychain Access Issues**:
```bash
# Reset keychain credentials
python CORE-PLATFORM/chromadb_intelligence_engine.py --reset-credentials

# Manual credential configuration
python CORE-PLATFORM/chromadb_intelligence_engine.py --manual-credential-setup
```

**Service Connectivity Problems**:
```bash
# Test individual services
python CORE-PLATFORM/chromadb_intelligence_engine.py --test-service anthropic
python CORE-PLATFORM/chromadb_intelligence_engine.py --test-service openai
```

### Memory and Performance Issues

**Low Memory Systems (8GB RAM)**:
```bash
# Configure conservative memory usage
python CORE-PLATFORM/hardware_profiler.py --configure-low-memory
```

**Apple Silicon Optimization**:
```bash
# Enable Apple Silicon specific optimizations
python CORE-PLATFORM/hardware_profiler.py --optimize-apple-silicon
```

## Advanced Installation Options

### Corporate Environment Setup

**Proxy Configuration**:
```bash
# Configure corporate proxy settings
./INSTALLATION/step_01_environment_setup.sh \
  --proxy http://corporate-proxy:8080 \
  --proxy-auth username:password
```

**Custom Certificate Authority**:
```bash
# Install corporate CA certificates
./INSTALLATION/step_01_environment_setup.sh --install-ca-certs /path/to/certs
```

### Multi-User Installation

**System-Wide Installation**:
```bash
# Install for all users (requires admin privileges)
sudo ./INSTALLATION/step_01_environment_setup.sh --system-wide
```

**Shared Configuration**:
```bash
# Create shared configuration templates
./INSTALLATION/step_05_final_configuration.sh --create-shared-templates
```

## Security Considerations

### Data Protection During Installation

- All downloads occur over HTTPS with certificate validation
- API credentials encrypted immediately upon entry
- No telemetry or usage data transmitted during installation
- Temporary files automatically cleaned after successful installation

### Network Security

- Minimal network access required (package downloads and API validation)
- No persistent network services installed or configured
- All AI processing occurs locally by default
- Optional cloud services require explicit user configuration

## Post-Installation Next Steps

### Initial Data Import

1. **Review Templates**: Examine `/TEMPLATES/` directory for data import workflows
2. **Configure Privacy Rules**: Set up document classification patterns
3. **Import Existing Data**: Process documents using appropriate template workflows
4. **Validate Processing**: Test semantic search and AI analysis capabilities

### Knowledge Management Setup

1. **Launch Obsidian**: Open the configured vault for knowledge management
2. **Review Templates**: Examine AI-enhanced note templates and structures
3. **Connect Documents**: Link processed documents with Obsidian notes
4. **Build Knowledge Graph**: Create connections between concepts and ideas

### Platform Optimization

1. **Performance Tuning**: Adjust settings based on typical usage patterns
2. **Privacy Refinement**: Fine-tune classification rules based on actual documents
3. **Workflow Integration**: Connect with existing productivity tools and workflows
4. **Backup Configuration**: Set up secure backup and synchronization options

This installation system provides a robust, professional deployment experience that transforms Mac computers into powerful, privacy-controlled AI intelligence platforms optimized for knowledge work and document analysis.