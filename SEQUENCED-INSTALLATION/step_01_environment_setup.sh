#!/bin/bash
# SEFIROT SEQUENCED INSTALLATION - STEP 1: Environment Setup
# Numbered sequence ready for GUI wrapper integration

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                        SEFIROT INSTALLATION SEQUENCE                        ║"
echo "║                             STEP 1: Environment Setup                       ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# GUI Integration Support
STEP_NUMBER=1
STEP_NAME="Environment Setup"
STEP_DESCRIPTION="Installing system prerequisites and development environment"

# Export step information for GUI wrapper
export SEFIROT_CURRENT_STEP=$STEP_NUMBER
export SEFIROT_CURRENT_STEP_NAME="$STEP_NAME"
export SEFIROT_CURRENT_STEP_DESCRIPTION="$STEP_DESCRIPTION"

echo -e "${GREEN}STEP $STEP_NUMBER: $STEP_NAME${NC}"
echo "Description: $STEP_DESCRIPTION"
echo "============================================="
echo ""

# Create step tracking directory
SEFIROT_INSTALL_DIR="$HOME/.sefirot/installation"
mkdir -p "$SEFIROT_INSTALL_DIR"

# Mark step as started
echo "started:$(date -Iseconds)" > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_status.txt"

# Step 1.1: Detect system capabilities
echo -e "${BLUE}Step 1.1: Detecting System Capabilities${NC}"
echo "----------------------------------------"

# Detect macOS version
MACOS_VERSION=$(sw_vers -productVersion)
echo "   ✅ macOS Version: $MACOS_VERSION"

# Detect architecture
ARCH=$(uname -m)
echo "   ✅ Architecture: $ARCH"

# Detect CPU cores
CPU_CORES=$(sysctl -n hw.physicalcpu)
LOGICAL_CORES=$(sysctl -n hw.logicalcpu)
echo "   ✅ CPU Cores: $CPU_CORES physical, $LOGICAL_CORES logical"

# Detect memory
MEMORY_GB=$(echo "scale=1; $(sysctl -n hw.memsize) / 1024 / 1024 / 1024" | bc)
echo "   ✅ Memory: ${MEMORY_GB}GB"

# Check for minimum requirements
echo ""
echo -e "${BLUE}Step 1.2: Checking Minimum Requirements${NC}"
echo "----------------------------------------"

REQUIREMENTS_MET=true

# Check macOS version (require Monterey 12.0+)
MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)
MACOS_MINOR=$(echo $MACOS_VERSION | cut -d. -f2)

if [ "$MACOS_MAJOR" -lt 12 ]; then
    echo -e "${RED}   ❌ macOS version too old (requires 12.0+, found $MACOS_VERSION)${NC}"
    REQUIREMENTS_MET=false
else
    echo -e "${GREEN}   ✅ macOS version compatible ($MACOS_VERSION)${NC}"
fi

# Check available disk space (require 10GB)
AVAILABLE_SPACE_GB=$(df -g "$HOME" | awk 'NR==2 {print $4}')
if [ "$AVAILABLE_SPACE_GB" -lt 10 ]; then
    echo -e "${RED}   ❌ Insufficient disk space (requires 10GB, available ${AVAILABLE_SPACE_GB}GB)${NC}"
    REQUIREMENTS_MET=false
else
    echo -e "${GREEN}   ✅ Sufficient disk space (${AVAILABLE_SPACE_GB}GB available)${NC}"
fi

# Check memory (require 8GB)
MEMORY_GB_INT=$(echo $MEMORY_GB | cut -d. -f1)
if [ "$MEMORY_GB_INT" -lt 8 ]; then
    echo -e "${YELLOW}   ⚠️  Low memory (${MEMORY_GB}GB, recommended 8GB+)${NC}"
else
    echo -e "${GREEN}   ✅ Sufficient memory (${MEMORY_GB}GB)${NC}"
fi

if [ "$REQUIREMENTS_MET" = false ]; then
    echo -e "${RED}❌ System requirements not met. Aborting installation.${NC}"
    echo "failed:system_requirements_not_met:$(date -Iseconds)" > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_status.txt"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 1.3: Installing Package Managers${NC}"
echo "--------------------------------------"

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "   📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ "$ARCH" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    else
        eval "$(/usr/local/bin/brew shellenv)"
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
    fi
    
    echo -e "${GREEN}   ✅ Homebrew installed successfully${NC}"
else
    echo -e "${GREEN}   ✅ Homebrew already installed${NC}"
fi

# Update Homebrew
echo "   📦 Updating Homebrew..."
brew update > /dev/null 2>&1
echo -e "${GREEN}   ✅ Homebrew updated${NC}"

echo ""
echo -e "${BLUE}Step 1.4: Installing System Dependencies${NC}"
echo "----------------------------------------"

# Essential system tools
SYSTEM_PACKAGES=(
    "git"
    "curl"
    "wget" 
    "tree"
    "jq"
    "bc"
    "coreutils"
)

for package in "${SYSTEM_PACKAGES[@]}"; do
    if ! brew list "$package" &> /dev/null; then
        echo "   📦 Installing $package..."
        brew install "$package" > /dev/null 2>&1
        echo -e "${GREEN}   ✅ $package installed${NC}"
    else
        echo -e "${GREEN}   ✅ $package already installed${NC}"
    fi
done

echo ""
echo -e "${BLUE}Step 1.5: Installing Nix Package Manager${NC}"
echo "----------------------------------------"

# Install Nix for declarative environment management
if ! command -v nix &> /dev/null; then
    echo "   📦 Installing Nix package manager..."
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    
    # Source Nix profile for current session
    if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
    
    echo -e "${GREEN}   ✅ Nix package manager installed${NC}"
    echo -e "${YELLOW}   ⚠️  You may need to restart your terminal after installation${NC}"
else
    echo -e "${GREEN}   ✅ Nix package manager already installed${NC}"
fi

echo ""
echo -e "${BLUE}Step 1.6: Installing Conda/Mamba${NC}"
echo "--------------------------------"

# Install Mamba (faster Conda alternative) for Python environment management
if ! command -v mamba &> /dev/null && ! command -v conda &> /dev/null; then
    echo "   📦 Installing Miniforge (Mamba/Conda)..."
    
    # Download appropriate installer based on architecture
    if [[ "$ARCH" == "arm64" ]]; then
        MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh"
    else
        MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh"
    fi
    
    curl -L "$MINIFORGE_URL" -o miniforge_installer.sh
    bash miniforge_installer.sh -b -p "$HOME/miniforge3"
    
    # Add to shell profile
    echo 'export PATH="$HOME/miniforge3/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(conda shell.zsh hook)"' >> ~/.zshrc
    
    # Initialize for current session
    export PATH="$HOME/miniforge3/bin:$PATH"
    eval "$(conda shell.zsh hook)"
    
    # Initialize mamba
    conda init zsh
    
    # Clean up installer
    rm miniforge_installer.sh
    
    echo -e "${GREEN}   ✅ Miniforge/Mamba installed successfully${NC}"
else
    echo -e "${GREEN}   ✅ Conda/Mamba environment already available${NC}"
fi

echo ""
echo -e "${BLUE}Step 1.7: Configuring Shell Environment${NC}"
echo "---------------------------------------"

# Create shell configuration for Sefirot
SEFIROT_SHELL_CONFIG="$HOME/.sefirot/shell_config.sh"
mkdir -p "$(dirname "$SEFIROT_SHELL_CONFIG")"

cat > "$SEFIROT_SHELL_CONFIG" << 'EOF'
# Sefirot Development Environment Configuration

# Sefirot paths
export SEFIROT_HOME="$HOME/.sefirot"
export SEFIROT_CONFIG="$SEFIROT_HOME/credentials.yaml"
export SEFIROT_VAULT_PATH="$HOME/SefirotVault"

# Development tools
export EDITOR="code"
export BROWSER="open"

# Performance optimizations based on hardware
SEFIROT_CPU_CORES=$(sysctl -n hw.physicalcpu)
export MAKEFLAGS="-j$SEFIROT_CPU_CORES"
export NUMBA_NUM_THREADS="$SEFIROT_CPU_CORES"

# Python optimizations
export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1

# ChromaDB configuration
export CHROMADB_DATA_PATH="$SEFIROT_HOME/chromadb"

# Helpful aliases
alias sefirot-status="cat $SEFIROT_HOME/device_info.yaml"
alias sefirot-logs="tail -f $SEFIROT_HOME/logs/sefirot.log"
alias sefirot-vault="cd $SEFIROT_VAULT_PATH"
alias sefirot-activate="source $SEFIROT_HOME/activate.sh"

echo "🚀 Sefirot development environment ready"
EOF

# Add to shell profile if not already present
if ! grep -q "# Sefirot Environment" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Sefirot Environment Auto-activation" >> ~/.zshrc
    echo "if [ -f \"$SEFIROT_SHELL_CONFIG\" ]; then" >> ~/.zshrc
    echo "    source \"$SEFIROT_SHELL_CONFIG\"" >> ~/.zshrc
    echo "fi" >> ~/.zshrc
fi

echo -e "${GREEN}   ✅ Shell environment configured${NC}"

echo ""
echo -e "${BLUE}Step 1.8: Creating Directory Structure${NC}"
echo "--------------------------------------"

# Create Sefirot directory structure
SEFIROT_DIRS=(
    "$HOME/.sefirot/logs"
    "$HOME/.sefirot/backups"
    "$HOME/.sefirot/chromadb"
    "$HOME/.sefirot/cache" 
    "$HOME/.sefirot/temp"
    "$HOME/.sefirot/installation"
)

for dir in "${SEFIROT_DIRS[@]}"; do
    mkdir -p "$dir"
    echo -e "${GREEN}   ✅ Created directory: $dir${NC}"
done

# Create vault directory if it doesn't exist
mkdir -p "$HOME/SefirotVault"
echo -e "${GREEN}   ✅ Created vault directory: $HOME/SefirotVault${NC}"

echo ""
echo -e "${BLUE}Step 1.9: Environment Validation${NC}"
echo "---------------------------------"

# Validate installations
VALIDATION_SUCCESS=true

# Check Homebrew
if command -v brew &> /dev/null; then
    echo -e "${GREEN}   ✅ Homebrew: $(brew --version | head -n1)${NC}"
else
    echo -e "${RED}   ❌ Homebrew not found${NC}"
    VALIDATION_SUCCESS=false
fi

# Check Git
if command -v git &> /dev/null; then
    echo -e "${GREEN}   ✅ Git: $(git --version)${NC}"
else
    echo -e "${RED}   ❌ Git not found${NC}"
    VALIDATION_SUCCESS=false
fi

# Check Nix (may not be available in current session)
if command -v nix &> /dev/null; then
    echo -e "${GREEN}   ✅ Nix: Available${NC}"
else
    echo -e "${YELLOW}   ⚠️  Nix: Not available in current session (restart terminal)${NC}"
fi

# Check Conda/Mamba
if command -v mamba &> /dev/null; then
    echo -e "${GREEN}   ✅ Mamba: $(mamba --version | head -n1)${NC}"
elif command -v conda &> /dev/null; then
    echo -e "${GREEN}   ✅ Conda: $(conda --version)${NC}"
else
    echo -e "${YELLOW}   ⚠️  Conda/Mamba: Not available in current session (restart terminal)${NC}"
fi

echo ""

# Mark step as completed
if [ "$VALIDATION_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ STEP $STEP_NUMBER COMPLETED SUCCESSFULLY${NC}"
    echo "completed:$(date -Iseconds)" > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_status.txt"
    
    # Create step completion marker for GUI
    cat > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_completion.json" << EOF
{
    "step_number": $STEP_NUMBER,
    "step_name": "$STEP_NAME",
    "status": "completed",
    "completion_time": "$(date -Iseconds)",
    "next_step": $(($STEP_NUMBER + 1)),
    "next_step_name": "Python Environment & Dependencies",
    "validation_success": true,
    "environment_ready": true
}
EOF
    
    echo ""
    echo "🎯 Environment Setup Complete!"
    echo "📋 System Summary:"
    echo "   • macOS $MACOS_VERSION ($ARCH architecture)"
    echo "   • ${MEMORY_GB}GB RAM, $CPU_CORES CPU cores"
    echo "   • Homebrew package manager installed"
    echo "   • Nix declarative environment installed"
    echo "   • Conda/Mamba Python environment installed"
    echo "   • Sefirot directory structure created"
    echo ""
    echo "🚀 Ready for Step 2: Python Environment & Dependencies"
    echo ""
    echo -e "${YELLOW}💡 Important: Restart your terminal to activate all new environment settings${NC}"
    echo ""
    
else
    echo -e "${RED}❌ STEP $STEP_NUMBER FAILED${NC}"
    echo "failed:validation_failed:$(date -Iseconds)" > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_status.txt"
    
    cat > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_completion.json" << EOF
{
    "step_number": $STEP_NUMBER,
    "step_name": "$STEP_NAME", 
    "status": "failed",
    "completion_time": "$(date -Iseconds)",
    "validation_success": false,
    "errors": ["Environment validation failed"]
}
EOF
    
    echo "Please restart your terminal and run this step again."
    exit 1
fi