#!/bin/bash
# SEFIROT COMPLETE UNINSTALL SCRIPT
# Comprehensive removal of all Sefirot components and configurations

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                            SEFIROT UNINSTALLER                              ║"
echo "║                    Complete System Removal & Cleanup                        ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

echo -e "${YELLOW}⚠️  WARNING: This will completely remove all Sefirot components${NC}"
echo ""
echo "This uninstaller will remove:"
echo "• Sefirot configuration directory (~/.sefirot)"
echo "• Sefirot Python conda environment"
echo "• Sefirot Obsidian vault (~/SefirotVault)"
echo "• All CLI tools and shell integrations"
echo "• Installation logs and backups"
echo ""
echo -e "${RED}🚨 This action cannot be undone!${NC}"
echo ""

# Confirmation prompt
read -p "Are you sure you want to completely uninstall Sefirot? (type 'UNINSTALL' to confirm): " confirmation

if [ "$confirmation" != "UNINSTALL" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}🗑️  Beginning Sefirot Uninstallation${NC}"
echo "======================================"
echo ""

# Track what we're removing
REMOVED_ITEMS=()
FAILED_ITEMS=()

echo -e "${BLUE}Step 1: Creating Pre-Uninstall Backup${NC}"
echo "------------------------------------"

BACKUP_DIR="$HOME/.sefirot_uninstall_backup_$(date +%Y%m%d_%H%M%S)"

if [ -d "$HOME/.sefirot" ]; then
    echo "   📦 Creating backup of Sefirot configuration..."
    cp -r "$HOME/.sefirot" "$BACKUP_DIR"
    echo -e "${GREEN}   ✅ Backup created: $BACKUP_DIR${NC}"
else
    echo -e "${YELLOW}   ⚠️  No Sefirot configuration found to backup${NC}"
fi

echo ""
echo -e "${BLUE}Step 2: Removing Python Environment${NC}"
echo "----------------------------------"

# Remove conda environment
export PATH="$HOME/miniforge3/bin:$PATH"
if command -v conda &> /dev/null; then
    eval "$(conda shell.bash hook)"
    
    if conda env list | grep -q "sefirot"; then
        echo "   🐍 Removing Sefirot conda environment..."
        conda env remove -n sefirot -y > /dev/null 2>&1
        echo -e "${GREEN}   ✅ Sefirot conda environment removed${NC}"
        REMOVED_ITEMS+=("Python conda environment")
    else
        echo -e "${YELLOW}   ⚠️  Sefirot conda environment not found${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Conda not available${NC}"
fi

echo ""
echo -e "${BLUE}Step 3: Removing Sefirot Configuration${NC}"
echo "-------------------------------------"

# Remove main Sefirot directory
if [ -d "$HOME/.sefirot" ]; then
    echo "   📂 Removing ~/.sefirot directory..."
    
    # Show what's being removed
    echo "      Contents:"
    ls -la "$HOME/.sefirot" | head -10
    if [ $(ls -1 "$HOME/.sefirot" | wc -l) -gt 8 ]; then
        echo "      ... and $(($(ls -1 "$HOME/.sefirot" | wc -l) - 8)) more items"
    fi
    
    rm -rf "$HOME/.sefirot"
    echo -e "${GREEN}   ✅ Sefirot configuration directory removed${NC}"
    REMOVED_ITEMS+=("Configuration directory ~/.sefirot")
else
    echo -e "${YELLOW}   ⚠️  ~/.sefirot directory not found${NC}"
fi

echo ""
echo -e "${BLUE}Step 4: Removing Obsidian Vault${NC}"
echo "------------------------------"

VAULT_PATH="$HOME/SefirotVault"
if [ -d "$VAULT_PATH" ]; then
    echo "   📚 Found Sefirot vault: $VAULT_PATH"
    
    # Show vault contents
    NOTE_COUNT=$(find "$VAULT_PATH" -name "*.md" 2>/dev/null | wc -l)
    echo "      Contains: $NOTE_COUNT markdown files"
    
    echo ""
    echo -e "${YELLOW}   ⚠️  The vault contains your notes and documents!${NC}"
    echo "   Do you want to:"
    echo "   1. Remove the vault completely"
    echo "   2. Keep the vault (rename to SefirotVault_backup)"
    echo "   3. Skip vault removal"
    echo ""
    read -p "   Choose option (1-3, default 2): " vault_choice
    
    case ${vault_choice:-2} in
        1)
            rm -rf "$VAULT_PATH"
            echo -e "${GREEN}   ✅ Sefirot vault removed completely${NC}"
            REMOVED_ITEMS+=("Obsidian vault $VAULT_PATH")
            ;;
        2)
            mv "$VAULT_PATH" "${VAULT_PATH}_backup"
            echo -e "${GREEN}   ✅ Vault renamed to ${VAULT_PATH}_backup${NC}"
            REMOVED_ITEMS+=("Vault moved to backup location")
            ;;
        3)
            echo -e "${YELLOW}   ⚠️  Vault removal skipped${NC}"
            ;;
    esac
else
    echo -e "${YELLOW}   ⚠️  Sefirot vault not found${NC}"
fi

echo ""
echo -e "${BLUE}Step 5: Removing Shell Integration${NC}"
echo "---------------------------------"

# Remove shell integration from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo "   🐚 Checking shell integration in ~/.zshrc..."
    
    # Create backup of .zshrc
    cp "$HOME/.zshrc" "$HOME/.zshrc.sefirot_backup"
    
    # Remove Sefirot-related lines
    REMOVED_LINES=0
    
    # Remove environment auto-activation
    if grep -q "# Sefirot Environment" "$HOME/.zshrc"; then
        sed -i.bak '/# Sefirot Environment Auto-activation/,+3d' "$HOME/.zshrc"
        REMOVED_LINES=$((REMOVED_LINES + 1))
    fi
    
    # Remove PATH additions
    if grep -q ".sefirot/bin" "$HOME/.zshrc"; then
        sed -i.bak '/.sefirot\/bin/d' "$HOME/.zshrc"
        REMOVED_LINES=$((REMOVED_LINES + 1))
    fi
    
    # Remove conda/miniforge additions (if they were added by Sefirot)
    if grep -q "miniforge3" "$HOME/.zshrc"; then
        echo "   📝 Found miniforge3 references in ~/.zshrc"
        echo "      These might be from Sefirot installation."
        read -p "      Remove miniforge3/conda shell integration? (y/n, default n): " remove_conda
        if [[ "$remove_conda" =~ ^[Yy] ]]; then
            sed -i.bak '/miniforge3/d' "$HOME/.zshrc"
            sed -i.bak '/conda shell/d' "$HOME/.zshrc"
            REMOVED_LINES=$((REMOVED_LINES + 1))
        fi
    fi
    
    if [ "$REMOVED_LINES" -gt 0 ]; then
        echo -e "${GREEN}   ✅ Removed $REMOVED_LINES shell integration entries${NC}"
        echo -e "${GREEN}   ✅ Original ~/.zshrc backed up to ~/.zshrc.sefirot_backup${NC}"
        REMOVED_ITEMS+=("Shell integration from ~/.zshrc")
    else
        echo -e "${YELLOW}   ⚠️  No shell integration found to remove${NC}"
        rm "$HOME/.zshrc.sefirot_backup"  # Remove unnecessary backup
    fi
else
    echo -e "${YELLOW}   ⚠️  ~/.zshrc not found${NC}"
fi

echo ""
echo -e "${BLUE}Step 6: Removing CLI Tools and Binaries${NC}"
echo "--------------------------------------"

# Check for CLI tools in common locations
CLI_LOCATIONS=(
    "$HOME/.local/bin/sefirot"
    "$HOME/.local/bin/sefirot-intelligence" 
    "$HOME/.local/bin/obsidian-sync"
    "/usr/local/bin/sefirot"
    "/usr/local/bin/sefirot-intelligence"
    "/usr/local/bin/obsidian-sync"
)

REMOVED_CLI_COUNT=0

for cli_path in "${CLI_LOCATIONS[@]}"; do
    if [ -f "$cli_path" ]; then
        rm "$cli_path"
        echo -e "${GREEN}   ✅ Removed CLI tool: $cli_path${NC}"
        REMOVED_CLI_COUNT=$((REMOVED_CLI_COUNT + 1))
    fi
done

if [ "$REMOVED_CLI_COUNT" -gt 0 ]; then
    REMOVED_ITEMS+=("$REMOVED_CLI_COUNT CLI tools")
else
    echo -e "${YELLOW}   ⚠️  No CLI tools found in standard locations${NC}"
fi

echo ""
echo -e "${BLUE}Step 7: Optional Component Removal${NC}"
echo "---------------------------------"

echo "   🤔 The following components were installed by Sefirot but might be used by other applications:"
echo ""

# Check for system-wide components
OPTIONAL_REMOVALS=()

# Check for Obsidian
if [ -d "/Applications/Obsidian.app" ]; then
    echo "   📝 Obsidian.app - Knowledge management application"
    read -p "      Remove Obsidian application? (y/n, default n): " remove_obsidian
    if [[ "$remove_obsidian" =~ ^[Yy] ]]; then
        rm -rf "/Applications/Obsidian.app"
        echo -e "${GREEN}      ✅ Obsidian application removed${NC}"
        OPTIONAL_REMOVALS+=("Obsidian application")
    fi
fi

# Check for Homebrew packages
if command -v brew &> /dev/null; then
    echo "   🍺 Homebrew packages installed by Sefirot:"
    echo "      git, curl, wget, tree, jq, bc, coreutils"
    read -p "      Remove these Homebrew packages? (y/n, default n): " remove_brew_packages
    if [[ "$remove_brew_packages" =~ ^[Yy] ]]; then
        SEFIROT_PACKAGES=("git" "curl" "wget" "tree" "jq" "bc" "coreutils")
        for package in "${SEFIROT_PACKAGES[@]}"; do
            if brew list "$package" &> /dev/null; then
                brew uninstall "$package" > /dev/null 2>&1 || echo "      ⚠️ Could not remove $package"
            fi
        done
        echo -e "${GREEN}      ✅ Attempted to remove Sefirot-installed Homebrew packages${NC}"
        OPTIONAL_REMOVALS+=("Homebrew packages")
    fi
fi

# Check for Miniforge/Conda
if [ -d "$HOME/miniforge3" ]; then
    echo "   🐍 Miniforge3 (conda/mamba) - Python environment manager"
    echo "      Location: ~/miniforge3"
    read -p "      Remove Miniforge3 completely? (y/n, default n): " remove_miniforge
    if [[ "$remove_miniforge" =~ ^[Yy] ]]; then
        rm -rf "$HOME/miniforge3"
        echo -e "${GREEN}      ✅ Miniforge3 removed${NC}"
        OPTIONAL_REMOVALS+=("Miniforge3 Python environment manager")
    fi
fi

# Check for Nix
if command -v nix &> /dev/null; then
    echo "   ❄️  Nix package manager - Declarative environment manager"
    read -p "      Remove Nix package manager? (y/n, default n): " remove_nix
    if [[ "$remove_nix" =~ ^[Yy] ]]; then
        echo "      🔄 Removing Nix (this may take a moment)..."
        if [ -f "/nix/uninstall" ]; then
            sudo /nix/uninstall
        else
            # Manual Nix removal
            sudo rm -rf /nix
            sudo rm -f /etc/profile.d/nix.sh
            sudo rm -f /etc/bash.bashrc.backup-before-nix
            sudo rm -f /etc/bashrc.backup-before-nix
        fi
        echo -e "${GREEN}      ✅ Nix package manager removed${NC}"
        OPTIONAL_REMOVALS+=("Nix package manager")
    fi
fi

if [ ${#OPTIONAL_REMOVALS[@]} -gt 0 ]; then
    REMOVED_ITEMS+=("${OPTIONAL_REMOVALS[@]}")
fi

echo ""
echo -e "${BLUE}Step 8: Cleaning Up Temporary Files${NC}"
echo "----------------------------------"

# Clean up various temporary locations
TEMP_LOCATIONS=(
    "$HOME/.cache/sefirot"
    "$HOME/.cache/chromadb"
    "$HOME/.cache/sentence-transformers"
    "/tmp/sefirot*"
    "$HOME/Downloads/miniforge_installer.sh"
)

CLEANED_COUNT=0

for temp_path in "${TEMP_LOCATIONS[@]}"; do
    if ls $temp_path &> /dev/null; then
        rm -rf $temp_path
        echo -e "${GREEN}   ✅ Cleaned: $temp_path${NC}"
        CLEANED_COUNT=$((CLEANED_COUNT + 1))
    fi
done

if [ "$CLEANED_COUNT" -gt 0 ]; then
    REMOVED_ITEMS+=("$CLEANED_COUNT temporary file locations")
else
    echo -e "${YELLOW}   ⚠️  No temporary files found to clean${NC}"
fi

echo ""
echo -e "${BLUE}Step 9: Final System Cleanup${NC}"
echo "---------------------------"

# Update shell database
if command -v rehash &> /dev/null; then
    rehash
    echo -e "${GREEN}   ✅ Shell command database updated${NC}"
fi

# Clear environment variables for current session
unset SEFIROT_HOME SEFIROT_CONFIG SEFIROT_VAULT_PATH CHROMADB_DATA_PATH
echo -e "${GREEN}   ✅ Environment variables cleared${NC}"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                        🗑️  UNINSTALLATION COMPLETE 🗑️                        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Summary report
echo -e "${GREEN}📊 Removal Summary${NC}"
echo "=================="
echo ""

if [ ${#REMOVED_ITEMS[@]} -gt 0 ]; then
    echo -e "${GREEN}✅ Successfully Removed:${NC}"
    for item in "${REMOVED_ITEMS[@]}"; do
        echo "   • $item"
    done
    echo ""
fi

if [ ${#FAILED_ITEMS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Could Not Remove:${NC}"
    for item in "${FAILED_ITEMS[@]}"; do
        echo "   • $item"
    done
    echo ""
fi

echo -e "${BLUE}📦 Backup Information${NC}"
echo "===================="
echo "• Pre-uninstall backup: $BACKUP_DIR"
if [ -f "$HOME/.zshrc.sefirot_backup" ]; then
    echo "• Shell config backup: ~/.zshrc.sefirot_backup"
fi
echo ""

echo -e "${YELLOW}🔄 Post-Uninstall Actions${NC}"
echo "========================="
echo "• Restart your terminal to clear environment changes"
echo "• Check ~/.zshrc for any remaining references"
echo "• Review backup files before deleting them"
echo ""

echo -e "${GREEN}✅ Sefirot has been successfully uninstalled from your system.${NC}"
echo ""

# Optional cleanup of uninstaller
echo -e "${BLUE}🧹 Cleanup${NC}"
echo "=========="
read -p "Remove this uninstaller script? (y/n, default y): " remove_self
if [[ "${remove_self:-y}" =~ ^[Yy] ]]; then
    SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    echo "Removing uninstaller: $SCRIPT_PATH"
    # Use a subshell to remove this script after it exits
    (sleep 2 && rm -f "$SCRIPT_PATH") &
fi

echo ""
echo "Thank you for trying Sefirot! 👋"
echo ""

# Create uninstall completion marker
cat > "/tmp/sefirot_uninstall_complete.json" << EOF
{
    "uninstall_completed": true,
    "completion_date": "$(date -Iseconds)",
    "items_removed": $(echo "${REMOVED_ITEMS[@]}" | wc -w),
    "backup_location": "$BACKUP_DIR",
    "status": "success"
}
EOF