# Sefirot Troubleshooting Guide

## Installation Issues

### Electron Installer Won't Start

**Symptoms**: `npm start` fails or shows errors
**Solutions**:
```bash
# Clear npm cache and reinstall
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Check Node.js version (requires 16+)
node --version

# Install required Node.js version via Homebrew
brew install node@18
```

### Permission Denied Errors

**Symptoms**: Installation scripts fail with permission errors
**Solutions**:
```bash
# Make scripts executable
chmod +x ./INSTALLATION/*.sh

# Run with proper permissions
sudo ./INSTALLATION/step_01_environment_setup.sh
```

### Homebrew Installation Fails

**Symptoms**: Step 1 fails to install Homebrew
**Solutions**:
```bash
# Manual Homebrew installation
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (M1/M2 Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Add to PATH (Intel Macs)
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

## Python Environment Issues

### Conda Command Not Found

**Symptoms**: `conda: command not found`
**Solutions**:
```bash
# Initialize conda for your shell
conda init zsh
source ~/.zshrc

# Or add manually to PATH
echo 'export PATH="/opt/homebrew/anaconda3/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Package Installation Fails

**Symptoms**: ChromaDB or AI packages fail to install
**Solutions**:
```bash
# Update conda first
conda update conda

# Install with specific Python version
conda create -n sefirot python=3.11
conda activate sefirot

# Install packages individually
conda install -c conda-forge chromadb
pip install transformers sentence-transformers
```

### Apple Silicon Compatibility

**Symptoms**: Packages fail on M1/M2/M3 Macs
**Solutions**:
```bash
# Use conda-forge channel for ARM packages
conda install -c conda-forge -c pytorch pytorch

# Force ARM64 architecture
arch -arm64 brew install python@3.11
```

## API and Credential Issues

### API Keys Not Working

**Symptoms**: Authentication errors or quota exceeded
**Solutions**:
1. **Verify Key Format**:
   - Anthropic: Must include `sk-ant-api03-` prefix
   - OpenAI: Must include `sk-` prefix
   
2. **Check Quotas**:
   ```bash
   # Test individual APIs
   sefirot test anthropic
   sefirot test openai
   ```

3. **Recreate Keys**: Generate new keys from provider dashboards

### Keychain Access Denied

**Symptoms**: macOS keychain permission errors
**Solutions**:
```bash
# Reset keychain permissions
security delete-generic-password -s "sefirot-api-keys" ~/Library/Keychains/login.keychain-db

# Allow Terminal/Electron keychain access in System Preferences
# → Security & Privacy → Privacy → Full Disk Access
```

## ChromaDB Issues

### Database Initialization Fails

**Symptoms**: ChromaDB cannot create database files
**Solutions**:
```bash
# Check permissions on SefirotVault directory
ls -la ~/SefirotVault/

# Recreate vault with correct permissions
rm -rf ~/SefirotVault/.chromadb
sefirot init --force
```

### Memory Issues with Large Documents

**Symptoms**: Out of memory errors during processing
**Solutions**:
```bash
# Increase memory allocation
export CHROMADB_MAX_BATCH_SIZE=100

# Process documents in smaller batches
sefirot sync --batch-size 50
```

## Obsidian Integration Issues

### Obsidian Not Installing via Homebrew

**Symptoms**: Obsidian cask installation fails
**Solutions**:
```bash
# Install manually
brew install --cask obsidian

# Or download from obsidian.md and install manually
```

### Plugin Installation Fails

**Symptoms**: Community plugins not installing
**Solutions**:
1. **Manual Plugin Installation**:
   - Download plugin releases from GitHub
   - Place in `~/SefirotVault/.obsidian/plugins/`

2. **Enable Community Plugins**:
   - Open Obsidian → Settings → Community Plugins
   - Turn off Safe Mode
   - Browse and install plugins

### Vault Not Recognized

**Symptoms**: Obsidian doesn't recognize SefirotVault
**Solutions**:
```bash
# Recreate vault structure
mkdir -p ~/SefirotVault/.obsidian
echo '{"isNewVault": false}' > ~/SefirotVault/.obsidian/app.json

# Open vault manually in Obsidian
# File → Open Folder as Vault → Select SefirotVault
```

## Performance Issues

### Slow Processing

**Symptoms**: Document processing takes very long
**Solutions**:
```bash
# Enable hardware acceleration
sefirot config set use_gpu true

# Reduce batch size for memory constrained systems
sefirot config set batch_size 32

# Use faster embedding models
sefirot config set embedding_model "sentence-transformers/all-MiniLM-L6-v2"
```

### High CPU Usage

**Symptoms**: System becomes unresponsive during processing
**Solutions**:
```bash
# Limit CPU usage
sefirot config set max_workers 2

# Process in background with lower priority
nice -n 10 sefirot sync
```

## Network and Connectivity

### API Timeouts

**Symptoms**: Network requests timing out
**Solutions**:
```bash
# Increase timeout settings
sefirot config set api_timeout 120

# Use alternative DNS
networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
```

### Firewall Issues

**Symptoms**: API calls blocked by corporate firewall
**Solutions**:
1. **Configure Proxy**:
   ```bash
   export https_proxy=http://proxy.company.com:8080
   sefirot sync
   ```

2. **Whitelist Domains**:
   - api.anthropic.com
   - api.openai.com
   - Your Shopify store domain

## Diagnostic Commands

### System Status
```bash
# Complete system check
sefirot doctor

# Individual component checks
sefirot test-environment
sefirot test-apis
sefirot test-chromadb
sefirot test-obsidian
```

### Log Analysis
```bash
# View recent logs
sefirot logs --tail 50

# Debug mode for detailed output
sefirot sync --debug

# Export diagnostic information
sefirot export-diagnostics ~/sefirot-diagnostics.zip
```

## Getting Help

### Built-in Help
```bash
# General help
sefirot help

# Specific command help
sefirot help sync
sefirot help config
sefirot help test
```

### Community Support
- **Documentation**: Check INSTALLATION-GUIDE.md
- **Issues**: Common problems in this troubleshooting guide
- **Email Support**: hello@sefirot.dev

#### macOS Version Compatibility

**Symptoms**: Installation fails on older macOS versions
**Solutions**:
```bash
# Check macOS version
sw_vers

# macOS 12.0+ required - upgrade if needed
# softwareupdate -l
# softwareupdate -i -a
```

### Xcode Command Line Tools Issues

**Symptoms**: Compilation errors during package installation
**Solutions**:
```bash
# Install/update Xcode Command Line Tools
xcode-select --install

# Reset tools if corrupted
sudo xcode-select --reset
sudo xcode-select --install
```

### Security and Privacy Settings

**Symptoms**: Installation blocked by macOS security settings
**Solutions**:
1. **Allow apps from App Store and identified developers**:
   - System Preferences → Security & Privacy → General
   - Allow apps downloaded from: "App Store and identified developers"

2. **Terminal Full Disk Access** (for keychain operations):
   - System Preferences → Security & Privacy → Privacy
   - Full Disk Access → Add Terminal

3. **Developer Tools Access**:
   - Allow Terminal to access Downloads, Documents folders

## Advanced Diagnostics

If issues persist, collect this information before contacting support:

```bash
# System information
system_profiler SPHardwareDataType
sw_vers

# Environment information
conda list
pip list
brew list

# Sefirot configuration
python CORE-PLATFORM/chromadb_intelligence_engine.py health
ls -la ~/.sefirot/
```

## Recovery Procedures

### Complete Reinstall
```bash
# Remove everything
./UNINSTALL/sefirot_uninstall.sh

# Start fresh installation
cd SEFIROT-COMPLETE-INSTALLER
npm start
```

### Backup and Restore
```bash
# Backup current configuration
sefirot backup ~/sefirot-backup-$(date +%Y%m%d).tar.gz

# Restore from backup
sefirot restore ~/sefirot-backup-20240101.tar.gz
```