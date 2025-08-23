# LLM Context Guide for Sefirot Intelligence Platform

## Overview for AI Assistants

This document provides context for Large Language Models (LLMs) like Claude, ChatGPT, and others when helping users work with the Sefirot Intelligence Platform.

## Platform Architecture

### **Core Components**
- **ChromaDB Intelligence Engine**: Local vector database for semantic search and document processing
- **3-Tier Privacy Framework**: Automatic content classification (Public, Business, Personal)
- **Obsidian Integration**: Visual knowledge management with AI enhancement
- **Cross-Platform Deployment**: macOS-focused with multi-device state transfer capability

### **Technology Stack**
- **Frontend**: Electron GUI with professional Sefirot Consulting branding
- **Backend**: Python 3.11 with Conda environment management
- **AI/ML**: ChromaDB, transformers, sentence-transformers, spaCy
- **Vector Storage**: Local ChromaDB with optional Pinecone cloud backup
- **Knowledge Management**: Obsidian with custom vault structure and plugins

## Installation Context

### **GUI Installer Process**
The Electron installer follows a 5-phase approach:
1. **Welcome & System Check**: Hardware profiling and requirements validation
2. **Credential Collection**: Secure API key management with keychain storage
3. **Automated Installation**: 5 numbered steps with real-time progress tracking
4. **Interactive Tour**: AI butler guides users through platform capabilities
5. **Platform Ready**: Obsidian launch and CLI tool integration

### **Required API Services**
- **Essential**: Anthropic Claude Pro (`sk-ant-api03-...`), OpenAI (`sk-...`)
- **Optional**: Shopify (e-commerce), RunPod/Paperspace (GPU), Pinecone (cloud vectors)

## Common User Queries & Responses

### **Installation Issues**
When users report installation problems:
1. **Check System Requirements**: macOS 12.0+, 8GB+ RAM, 10GB+ storage
2. **Verify Node.js**: Version 16+ required for Electron installer
3. **Permission Issues**: Installation requires admin privileges for system packages
4. **Network Connectivity**: Internet required for package downloads and API validation

**Diagnostic Commands to Suggest**:
```bash
sefirot doctor          # Complete system health check
sefirot test-apis       # Verify API connectivity
sefirot status          # Component status overview
sefirot logs --tail 50  # Recent log analysis
```

### **Usage and Workflow Questions**
When users need help with platform usage:

**Document Processing**:
```bash
sefirot sync ~/Documents/        # Process documents from folder
sefirot sync --batch-size 50     # Process in smaller batches for memory
sefirot sync --privacy-tier business  # Process with specific privacy tier
```

**Querying Intelligence**:
```bash
sefirot query "project planning documents"
sefirot search --semantic "customer feedback analysis" 
sefirot find --context "meeting notes from last quarter"
```

**Configuration Management**:
```bash
sefirot config show              # Display current configuration
sefirot config set use_gpu true  # Enable GPU acceleration
sefirot config privacy           # Adjust privacy settings
```

## Privacy Framework Context

### **3-Tier Classification System**
- **Public**: Open information, full AI processing allowed
- **Business**: Work-related content, local processing preferred
- **Personal**: Private information, strictly local processing only

### **Automatic Classification Logic**
The platform uses spaCy NLP + regex patterns to automatically classify content:
- **Personal Indicators**: SSN, credit cards, personal addresses, family references
- **Business Indicators**: Company names, project codes, internal processes
- **Public Indicators**: Published content, general knowledge, public websites

## Technical Troubleshooting Context

### **Common Issues & Solutions**

**Python Environment Problems**:
- Platform uses Conda with dedicated `sefirot` environment
- Python 3.11 specifically for compatibility with AI/ML libraries
- Apple Silicon requires `conda-forge` channel for ARM64 packages

**ChromaDB Issues**:
- Database files stored in `~/SefirotVault/.chromadb/`
- Memory issues: Reduce batch size with `--batch-size` parameter
- Persistence problems: Check file permissions on vault directory

**Obsidian Integration**:
- Vault located at `~/SefirotVault/`
- Essential plugins: Dataview, Templater, Calendar, Graph Analysis
- Custom templates for different document types and privacy tiers

**API Connectivity**:
- Keys stored in macOS keychain for security
- Test individual services with `sefirot test anthropic` or `sefirot test openai`
- Proxy support available for corporate environments

### **Performance Optimization**
For users with performance concerns:
```bash
# Enable hardware acceleration
sefirot config set use_gpu true
sefirot config set hardware_optimization auto

# Adjust processing parameters
sefirot config set max_workers 4
sefirot config set batch_size 32
sefirot config set embedding_model "sentence-transformers/all-MiniLM-L6-v2"
```

## Development Context

### **File Structure for Reference**
```
SEFIROT-COMPLETE-INSTALLER/
├── main.js                    # Electron main process
├── preload.js                 # Secure IPC bridge  
├── renderer/index.html        # Professional GUI interface
├── CORE-PLATFORM/            # Python AI engine modules
├── SEQUENCED-INSTALLATION/   # 5-step automation scripts
├── DOCUMENTATION/            # Complete user guides
└── assets/                   # Sefirot branding materials
```

### **Key Python Modules**
- `chromadb_intelligence_engine.py`: Core AI processing and semantic search
- `vault_transplantation_system.py`: Multi-device environment migration
- `hardware_profiler.py`: Performance optimization for different Mac configurations
- `user_settings_manager.py`: Configuration and preference management

## Support Escalation

### **Built-in Help System**
Users have access to comprehensive built-in help:
```bash
sefirot help                 # General help overview
sefirot help query          # Specific command help
sefirot help config         # Configuration guidance
sefirot export-diagnostics  # Generate support bundle
```

### **Documentation Hierarchy**
1. **Built-in Tour**: Interactive AI butler guides users through features
2. **Installation Guide**: Complete setup instructions with GUI workflow
3. **API Credentials Guide**: Service setup and key management
4. **Troubleshooting Guide**: Common issues and diagnostic procedures
5. **This LLM Context**: Technical reference for AI assistants

### **Professional Support**
- **Email**: hello@sefirot.dev for technical escalation
- **Built-in Diagnostics**: Platform generates comprehensive diagnostic reports
- **Community**: Users can reference troubleshooting documentation first

## Branding & Communication Style

When discussing Sefirot with users, maintain the **Sefirot Consulting** brand voice:
- **Professional yet approachable**: Technical excellence with accessible explanations
- **Wisdom-oriented**: "As above, so below - your knowledge becomes your wisdom"
- **Privacy-focused**: Emphasis on local-first processing and user control
- **Intelligence-oriented**: Focus on enhancing human intelligence, not replacing it

### **Visual Identity References**
- **Colors**: Gold (#D4AF37) and charcoal (#2C3E50) primary palette
- **Symbolism**: Tree of Life (Sefirot) representing connected knowledge
- **Professional**: Clean, modern interface design with mystical touches

## Version & Compatibility Notes

- **Target Platform**: macOS 12.0+ (Intel x64 and Apple Silicon)
- **Python Version**: 3.11 (managed via Conda)
- **Electron Version**: Latest LTS for security and performance
- **Node.js**: Version 16+ required for Electron compatibility
- **Architecture Support**: Universal binary support for Intel and Apple Silicon

This context enables AI assistants to provide accurate, helpful guidance to Sefirot Intelligence Platform users while maintaining brand consistency and technical accuracy.