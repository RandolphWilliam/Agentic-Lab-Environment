#!/bin/bash
# SEFIROT SEQUENCED INSTALLATION - STEP 4: Obsidian Vault Integration
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
echo "║                        STEP 4: Obsidian Vault Integration                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# GUI Integration Support
STEP_NUMBER=4
STEP_NAME="Obsidian Vault Integration"
STEP_DESCRIPTION="Installing Obsidian with custom plugins and vault integration"

# Export step information for GUI wrapper
export SEFIROT_CURRENT_STEP=$STEP_NUMBER
export SEFIROT_CURRENT_STEP_NAME="$STEP_NAME"
export SEFIROT_CURRENT_STEP_DESCRIPTION="$STEP_DESCRIPTION"

echo -e "${GREEN}STEP $STEP_NUMBER: $STEP_NAME${NC}"
echo "Description: $STEP_DESCRIPTION"
echo "====================================================="
echo ""

# Check prerequisites
SEFIROT_INSTALL_DIR="$HOME/.sefirot/installation"
mkdir -p "$SEFIROT_INSTALL_DIR"

# Verify Step 3 completed
if [ ! -f "$SEFIROT_INSTALL_DIR/step_3_status.txt" ] || ! grep -q "completed" "$SEFIROT_INSTALL_DIR/step_3_status.txt"; then
    echo -e "${RED}❌ Step 3 (ChromaDB Platform) must be completed first${NC}"
    echo "Please run step_03_chromadb_platform.sh first."
    exit 1
fi

# Mark step as started
echo "started:$(date -Iseconds)" > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_status.txt"

echo -e "${BLUE}Step 4.1: Installing Obsidian Application${NC}"
echo "----------------------------------------"

# Check if Obsidian is already installed
if [ -d "/Applications/Obsidian.app" ]; then
    echo -e "${GREEN}   ✅ Obsidian already installed${NC}"
else
    echo "   📦 Installing Obsidian via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install --cask obsidian > /dev/null 2>&1
        echo -e "${GREEN}   ✅ Obsidian installed successfully${NC}"
    else
        echo -e "${RED}   ❌ Homebrew not available for Obsidian installation${NC}"
        echo "   💡 Please install Obsidian manually from https://obsidian.md/"
        echo "   Then re-run this step."
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}Step 4.2: Creating Sefirot Vault Structure${NC}"
echo "-----------------------------------------"

# Create Sefirot vault directory structure
VAULT_PATH="$HOME/SefirotVault"
mkdir -p "$VAULT_PATH"

# Create vault directory structure
VAULT_DIRS=(
    "01-Inbox"
    "02-Projects" 
    "03-Areas"
    "04-Resources"
    "05-Archive"
    "Templates"
    "Attachments"
    "Scripts"
    "_private"
    "_system"
)

for dir in "${VAULT_DIRS[@]}"; do
    mkdir -p "$VAULT_PATH/$dir"
    echo -e "${GREEN}   ✅ Created: $dir${NC}"
done

echo ""
echo -e "${BLUE}Step 4.3: Installing Essential Obsidian Plugins${NC}"
echo "----------------------------------------------"

# Create Obsidian configuration directory
OBSIDIAN_CONFIG_DIR="$VAULT_PATH/.obsidian"
mkdir -p "$OBSIDIAN_CONFIG_DIR"/{plugins,themes,snippets}

# Core plugins configuration
cat > "$OBSIDIAN_CONFIG_DIR/core-plugins.json" << 'EOF'
[
  "file-explorer",
  "global-search",
  "switcher",
  "graph",
  "backlink",
  "outgoing-link",
  "tag-pane",
  "page-preview",
  "daily-notes",
  "templates",
  "note-composer",
  "command-palette",
  "markdown-importer",
  "zk-prefixer",
  "random-note",
  "outline",
  "word-count",
  "slides",
  "audio-recorder",
  "workspaces",
  "file-recovery"
]
EOF

# Community plugins manifest
cat > "$OBSIDIAN_CONFIG_DIR/community-plugins.json" << 'EOF'
[
  "dataview",
  "templater-obsidian",
  "obsidian-git",
  "calendar",
  "advanced-tables",
  "obsidian-mind-map",
  "natural-language-dates",
  "tag-wrangler",
  "recent-files-obsidian",
  "smart-random-note",
  "obsidian-kanban"
]
EOF

echo -e "${GREEN}   ✅ Plugin configuration created${NC}"

# Download and install key community plugins
PLUGINS_DIR="$OBSIDIAN_CONFIG_DIR/plugins"

# Essential plugin installations
ESSENTIAL_PLUGINS=(
    "dataview:blacksmithgu/obsidian-dataview"
    "templater-obsidian:SilentVoid13/Templater"
    "obsidian-git:denolehov/obsidian-git"
    "calendar:liamcain/obsidian-calendar-plugin"
    "advanced-tables:tgrosinger/advanced-tables-obsidian"
)

echo "   📦 Installing essential community plugins..."

for plugin_info in "${ESSENTIAL_PLUGINS[@]}"; do
    IFS=':' read -r plugin_id github_repo <<< "$plugin_info"
    plugin_dir="$PLUGINS_DIR/$plugin_id"
    
    if [ ! -d "$plugin_dir" ]; then
        echo "      Installing $plugin_id..."
        mkdir -p "$plugin_dir"
        
        # Download plugin from GitHub releases
        curl -sL "https://api.github.com/repos/$github_repo/releases/latest" | \
        python3 -c "
import json, sys, urllib.request
data = json.load(sys.stdin)
for asset in data.get('assets', []):
    if asset['name'] in ['main.js', 'manifest.json', 'styles.css']:
        print(asset['browser_download_url'])
" | while read url; do
            if [ -n "$url" ]; then
                filename=$(basename "$url")
                curl -sL "$url" -o "$plugin_dir/$filename"
            fi
        done
        
        echo -e "${GREEN}      ✅ $plugin_id installed${NC}"
    else
        echo -e "${GREEN}      ✅ $plugin_id already installed${NC}"
    fi
done

echo ""
echo -e "${BLUE}Step 4.4: Creating Sefirot-Specific Templates${NC}"
echo "--------------------------------------------"

# Daily note template
cat > "$VAULT_PATH/Templates/Daily Note.md" << 'EOF'
# {{date}}

## 🎯 Daily Focus
- [ ] 

## 📝 Notes
- 

## 🔍 Sefirot Insights
Query ChromaDB for related content:
```dataview
LIST
FROM "01-Inbox" OR "02-Projects" OR "03-Areas"
WHERE contains(file.name, "{{date:YYYY-MM-DD}}")
```

## 🔗 Connections
- 

## 📊 Metrics
- Documents processed: 
- New connections discovered: 

---
*Generated with Sefirot Intelligence Platform*
EOF

# Project template
cat > "$VAULT_PATH/Templates/Project.md" << 'EOF'
# {{title}}

## 📋 Project Overview
- **Status:** #project/active
- **Created:** {{date}}
- **Privacy Tier:** #tier2/business

## 🎯 Objectives
- [ ] 

## 📚 Resources
- 

## 🤖 AI Analysis
```dataview
TABLE
FROM "04-Resources"
WHERE contains(tags, "{{title:lower}}")
```

## 🔗 Related Notes
```dataview
LIST
WHERE contains(file.outlinks, this.file.name)
```

## 📈 Progress Tracking
- [ ] Initial research
- [ ] Planning phase
- [ ] Implementation
- [ ] Review and iteration

---
*Privacy Classification: Business Confidential*
*Processed by Sefirot Intelligence Engine*
EOF

# Meeting template
cat > "$VAULT_PATH/Templates/Meeting.md" << 'EOF'
# Meeting: {{title}}

**Date:** {{date}}
**Participants:** 
**Privacy:** #tier2/business

## 📋 Agenda
- 

## 📝 Notes
- 

## ✅ Action Items
- [ ] 

## 🔗 Related Documents
```dataview
LIST
WHERE contains(tags, "meeting") AND date(file.cday) = date("{{date}}")
```

## 🤖 Follow-up Analysis
*Use Sefirot Intelligence to find related content and suggest next steps*

---
*Confidential business information - Internal use only*
EOF

echo -e "${GREEN}   ✅ Templates created${NC}"

echo ""
echo -e "${BLUE}Step 4.5: Setting Up Obsidian Configuration${NC}"
echo "------------------------------------------"

# Main Obsidian configuration
cat > "$OBSIDIAN_CONFIG_DIR/app.json" << 'EOF'
{
  "legacyEditor": false,
  "livePreview": true,
  "defaultViewMode": "preview",
  "useMarkdownLinks": true,
  "newLinkFormat": "shortest",
  "showFrontmatter": true,
  "foldHeading": true,
  "foldIndent": true,
  "showLineNumber": true,
  "spellcheck": true,
  "baseFontSize": 16,
  "theme": "moonstone",
  "cssTheme": "",
  "translucency": false
}
EOF

# Graph view configuration
cat > "$OBSIDIAN_CONFIG_DIR/graph.json" << 'EOF'
{
  "collapse-filter": false,
  "search": "",
  "showTags": true,
  "showAttachments": false,
  "hideUnresolved": false,
  "showOrphans": false,
  "collapse-color-groups": false,
  "colorGroups": [
    {
      "query": "tag:#project",
      "color": {
        "a": 1,
        "rgb": 5431378
      }
    },
    {
      "query": "tag:#tier1",
      "color": {
        "a": 1,
        "rgb": 5395168
      }
    },
    {
      "query": "tag:#tier2",
      "color": {
        "a": 1,
        "rgb": 16727142
      }
    },
    {
      "query": "tag:#tier3",
      "color": {
        "a": 1,
        "rgb": 16711935
      }
    }
  ],
  "collapse-display": false,
  "showArrow": true,
  "textFadeMultiplier": -1,
  "nodeSizeMultiplier": 1.2,
  "lineSizeMultiplier": 1,
  "collapse-forces": false,
  "centerStrength": 0.3,
  "repelStrength": 15,
  "linkStrength": 0.9,
  "linkDistance": 180,
  "scale": 1
}
EOF

# Daily notes configuration  
cat > "$OBSIDIAN_CONFIG_DIR/daily-notes.json" << 'EOF'
{
  "format": "YYYY-MM-DD",
  "folder": "01-Inbox",
  "template": "Templates/Daily Note"
}
EOF

# Templates configuration
cat > "$OBSIDIAN_CONFIG_DIR/templates.json" << 'EOF'
{
  "folder": "Templates"
}
EOF

echo -e "${GREEN}   ✅ Obsidian configuration files created${NC}"

echo ""
echo -e "${BLUE}Step 4.6: Creating Sefirot-ChromaDB Integration${NC}"
echo "---------------------------------------------"

# Create Python script for Obsidian-ChromaDB integration
INTEGRATION_SCRIPT="$VAULT_PATH/Scripts/sefirot_obsidian_sync.py"

cat > "$INTEGRATION_SCRIPT" << 'EOF'
#!/usr/bin/env python3
"""
Sefirot-Obsidian Integration Script
Synchronizes Obsidian vault with ChromaDB intelligence engine
"""

import os
import sys
import asyncio
import yaml
from pathlib import Path
from datetime import datetime

# Add Sefirot to path
sys.path.append(str(Path.home() / '.sefirot' / 'CORE-PLATFORM'))

try:
    from chromadb_intelligence_engine import ChromaDBIntelligenceEngine
    from vault_transplantation_system import VaultTransplantationSystem, VaultTransplantationConfig
except ImportError as e:
    print(f"Error importing Sefirot modules: {e}")
    sys.exit(1)

class ObsidianSefirotIntegration:
    """Integration between Obsidian vault and Sefirot intelligence"""
    
    def __init__(self, vault_path: str):
        self.vault_path = Path(vault_path)
        self.sefirot_dir = Path.home() / '.sefirot'
        self.intelligence_engine = None
        
    async def initialize(self):
        """Initialize the intelligence engine"""
        print("🚀 Initializing Sefirot-Obsidian integration...")
        self.intelligence_engine = ChromaDBIntelligenceEngine()
        await self.intelligence_engine.initialize_components()
        print("✅ Intelligence engine ready")
        
    async def sync_vault_to_chromadb(self):
        """Sync Obsidian vault to ChromaDB with privacy classification"""
        print("📄 Syncing vault to ChromaDB...")
        
        processed_count = 0
        
        # Process all markdown files in vault
        for md_file in self.vault_path.rglob('*.md'):
            # Skip system files
            if any(skip in str(md_file) for skip in ['.obsidian', '.trash', 'Templates']):
                continue
                
            try:
                print(f"   Processing: {md_file.name}")
                metadata = await self.intelligence_engine.process_document(str(md_file))
                processed_count += 1
                
                # Add Obsidian-specific metadata tag
                await self._add_obsidian_metadata_tag(md_file, metadata)
                
            except Exception as e:
                print(f"   ⚠️ Error processing {md_file.name}: {e}")
                
        print(f"✅ Processed {processed_count} documents")
        
    async def _add_obsidian_metadata_tag(self, file_path: Path, metadata):
        """Add Sefirot metadata as tag to Obsidian file"""
        try:
            content = file_path.read_text(encoding='utf-8')
            
            # Check if file has frontmatter
            if content.startswith('---'):
                # Add to existing frontmatter
                lines = content.split('\n')
                insert_index = -1
                for i, line in enumerate(lines[1:], 1):
                    if line.strip() == '---':
                        insert_index = i
                        break
                        
                if insert_index > 0:
                    privacy_tag = f"#{metadata.privacy_tier.value.replace('_', '/')}"
                    sefirot_tag = f"#sefirot/processed"
                    
                    # Add tags if not present
                    if 'tags:' not in content:
                        lines.insert(insert_index, f"tags: [{privacy_tag}, {sefirot_tag}]")
                    else:
                        # Append to existing tags
                        for i, line in enumerate(lines):
                            if line.startswith('tags:'):
                                if privacy_tag not in line and sefirot_tag not in line:
                                    lines[i] = line.rstrip() + f", {privacy_tag}, {sefirot_tag}"
                                break
                    
                    file_path.write_text('\n'.join(lines), encoding='utf-8')
                    
        except Exception as e:
            print(f"   Warning: Could not add metadata tags to {file_path.name}: {e}")
            
    async def find_related_notes(self, note_path: str, limit: int = 5):
        """Find related notes using semantic search"""
        try:
            note_content = Path(note_path).read_text(encoding='utf-8')
            
            # Extract key phrases for search
            lines = note_content.split('\n')
            search_text = ' '.join(lines[:5])  # First 5 lines
            
            results = await self.intelligence_engine.semantic_search(search_text, limit=limit)
            
            related_notes = []
            for result in results:
                source_file = result['metadata'].get('source_file')
                if source_file and source_file != note_path:
                    related_notes.append({
                        'path': source_file,
                        'similarity': 1 - result['distance'],
                        'preview': result['document'][:100] + '...'
                    })
                    
            return related_notes
            
        except Exception as e:
            print(f"Error finding related notes: {e}")
            return []
            
    async def generate_vault_insights(self):
        """Generate insights about the vault structure and content"""
        stats = await self.intelligence_engine.get_processing_stats()
        
        insights = {
            'vault_path': str(self.vault_path),
            'total_documents': stats['documents_processed'],
            'total_embeddings': stats['embeddings_created'],
            'privacy_distribution': stats['privacy_classifications'],
            'last_updated': datetime.now().isoformat()
        }
        
        # Save insights to vault
        insights_file = self.vault_path / '_system' / 'sefirot_insights.yaml'
        insights_file.parent.mkdir(exist_ok=True)
        
        with open(insights_file, 'w') as f:
            yaml.dump(insights, f, indent=2)
            
        print(f"📊 Vault insights saved to {insights_file}")
        return insights

async def main():
    """Main integration function"""
    vault_path = str(Path.home() / 'SefirotVault')
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
    else:
        command = 'sync'
        
    integration = ObsidianSefirotIntegration(vault_path)
    
    try:
        await integration.initialize()
        
        if command == 'sync':
            await integration.sync_vault_to_chromadb()
        elif command == 'insights':
            insights = await integration.generate_vault_insights()
            print("📊 Vault Insights:")
            for key, value in insights.items():
                print(f"   {key}: {value}")
        elif command == 'related':
            if len(sys.argv) > 2:
                note_path = sys.argv[2]
                related = await integration.find_related_notes(note_path)
                print(f"🔗 Related notes for {Path(note_path).name}:")
                for note in related:
                    print(f"   • {Path(note['path']).name} (similarity: {note['similarity']:.3f})")
            else:
                print("Usage: python sefirot_obsidian_sync.py related <note_path>")
        else:
            print("Available commands: sync, insights, related")
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
EOF

chmod +x "$INTEGRATION_SCRIPT"
echo -e "${GREEN}   ✅ Obsidian-ChromaDB integration script created${NC}"

echo ""
echo -e "${BLUE}Step 4.7: Creating Sample Vault Content${NC}"
echo "--------------------------------------"

# Welcome note
cat > "$VAULT_PATH/Welcome to Sefirot.md" << 'EOF'
# Welcome to Your Sefirot Vault! 🚀

Welcome to the Sefirot ChromaDB Intelligence Platform integrated with Obsidian. This vault is designed to work seamlessly with the Sefirot intelligence engine for enhanced knowledge management and discovery.

## 🧭 Vault Structure

- **01-Inbox**: New ideas, quick captures, daily notes
- **02-Projects**: Active projects with defined outcomes  
- **03-Areas**: Ongoing responsibilities and interests
- **04-Resources**: Reference materials and research
- **05-Archive**: Completed or inactive content
- **Templates**: Note templates for consistency
- **Scripts**: Sefirot integration scripts
- **_private**: Personal content (Tier 3 privacy)
- **_system**: System-generated files and insights

## 🤖 Sefirot Intelligence Features

### Privacy Classification
All notes are automatically classified into privacy tiers:
- `#tier1/public`: Safe for sharing and cloud processing
- `#tier2/business`: Confidential business information
- `#tier3/personal`: Private information requiring explicit consent

### Semantic Search
Use the Sefirot intelligence engine to find related content based on meaning, not just keywords.

### Smart Connections
Discover unexpected relationships between your notes using AI-powered analysis.

## 📝 Getting Started

1. **Create your first note**: Use `Cmd+N` or click the new note button
2. **Use templates**: Access templates with `Cmd+P` → "Templates: Insert template"
3. **Daily notes**: Press `Cmd+P` → "Daily notes: Open today's daily note"
4. **Graph view**: Press `Cmd+G` to see your knowledge graph
5. **Search**: Press `Cmd+O` for quick note switching

## 🔗 Sefirot Integration Commands

Run these from the Scripts directory:

```bash
# Sync vault to ChromaDB
python Scripts/sefirot_obsidian_sync.py sync

# Generate vault insights  
python Scripts/sefirot_obsidian_sync.py insights

# Find related notes
python Scripts/sefirot_obsidian_sync.py related "path/to/note.md"
```

## 🛡️ Privacy & Security

Your vault content is processed locally by default. The Sefirot intelligence engine respects privacy tiers:

- **Tier 1** content may be processed by cloud services with your consent
- **Tier 2** content requires abstraction before cloud processing
- **Tier 3** content is never sent to external services

## 📚 Resources

- [[Templates/Daily Note|Daily Note Template]]
- [[Templates/Project|Project Template]] 
- [[Templates/Meeting|Meeting Template]]

---
*Generated by Sefirot Intelligence Platform*
#sefirot/welcome #tier1/public
EOF

# Sample project note
cat > "$VAULT_PATH/02-Projects/Sefirot Setup.md" << 'EOF'
# Sefirot Setup Project

**Status:** #project/active
**Created:** {{date}}
**Privacy:** #tier2/business

## 🎯 Objective
Successfully set up and configure the Sefirot ChromaDB Intelligence Platform with Obsidian integration.

## ✅ Completed Tasks
- [x] Install system prerequisites
- [x] Set up Python environment
- [x] Initialize ChromaDB platform
- [x] Install and configure Obsidian
- [x] Create vault structure
- [ ] Test all integrations
- [ ] Customize workflows

## 📚 Resources
- [[Welcome to Sefirot]]
- [Sefirot Documentation](https://sefirot.dev)
- [Obsidian Help](https://help.obsidian.md)

## 🤖 AI Insights
The Sefirot intelligence engine can help discover patterns and connections in this project as it develops.

## 📈 Next Steps
1. Complete the full installation sequence
2. Test document processing capabilities
3. Explore semantic search features
4. Customize templates for specific workflows

---
*Project managed with Sefirot Intelligence Platform*
EOF

# Sample area note
cat > "$VAULT_PATH/03-Areas/Knowledge Management.md" << 'EOF'
# Knowledge Management

**Area:** Ongoing responsibility
**Privacy:** #tier2/business

## 🧠 Overview
This area encompasses all activities related to capturing, organizing, and retrieving knowledge effectively.

## 🎯 Goals
- Maintain comprehensive knowledge base
- Improve information retrieval
- Connect disparate pieces of information
- Build institutional knowledge

## 🛠️ Tools & Systems
- **Sefirot Intelligence Platform**: AI-powered knowledge processing
- **Obsidian**: Visual knowledge management
- **ChromaDB**: Vector database for semantic search
- **Templates**: Consistent note structure

## 📊 Metrics
- Notes created per week
- Cross-references discovered
- Search success rate
- Knowledge reuse frequency

## 🔗 Related Projects
```dataview
LIST
FROM "02-Projects"
WHERE contains(tags, "knowledge") OR contains(tags, "research")
```

---
*Enhanced by Sefirot Intelligence*
EOF

echo -e "${GREEN}   ✅ Sample vault content created${NC}"

echo ""
echo -e "${BLUE}Step 4.8: Setting Up Automated Vault Sync${NC}"
echo "----------------------------------------"

# Create automated sync script
SYNC_SCRIPT="$HOME/.sefirot/bin/obsidian-sync"

cat > "$SYNC_SCRIPT" << 'EOF'
#!/bin/bash
# Automated Obsidian-Sefirot sync script

echo "🔄 Syncing Obsidian vault with Sefirot Intelligence..."

# Activate Python environment
export PATH="$HOME/miniforge3/bin:$PATH"
eval "$(conda shell.bash hook)"
conda activate sefirot

# Run sync
cd "$HOME/SefirotVault"
python Scripts/sefirot_obsidian_sync.py sync

echo "✅ Sync completed"
EOF

chmod +x "$SYNC_SCRIPT"

# Add to PATH if not already there
if ! grep -q "$HOME/.sefirot/bin" ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.sefirot/bin:$PATH"' >> ~/.zshrc
fi

echo -e "${GREEN}   ✅ Automated sync script created: obsidian-sync${NC}"

echo ""
echo -e "${BLUE}Step 4.9: Plugin Configuration and Setup${NC}"
echo "---------------------------------------"

# Configure Dataview plugin
mkdir -p "$OBSIDIAN_CONFIG_DIR/plugins/dataview"
cat > "$OBSIDIAN_CONFIG_DIR/plugins/dataview/data.json" << 'EOF'
{
  "renderNullAs": "\\-",
  "taskCompletionTracking": false,
  "taskCompletionUseEmojiShorthand": false,
  "warnOnEmptyResult": true,
  "refreshEnabled": true,
  "refreshInterval": 2500,
  "defaultDateFormat": "MMMM dd, yyyy",
  "defaultDateTimeFormat": "h:mm a - MMMM dd, yyyy",
  "maxRecursiveRenderDepth": 4,
  "enableInlineDataview": true,
  "enableDataviewJs": false,
  "enableInlineDataviewJs": false,
  "prettyRenderInlineFields": true,
  "dataviewJsKeyword": "dataviewjs"
}
EOF

# Configure Templater plugin
mkdir -p "$OBSIDIAN_CONFIG_DIR/plugins/templater-obsidian"
cat > "$OBSIDIAN_CONFIG_DIR/plugins/templater-obsidian/data.json" << EOF
{
  "command_timeout": 5,
  "templates_folder": "Templates",
  "templates_pairs": [
    ["Daily", "Templates/Daily Note.md"],
    ["Project", "Templates/Project.md"],
    ["Meeting", "Templates/Meeting.md"]
  ],
  "trigger_on_file_creation": false,
  "enable_system_commands": false,
  "shell_path": "",
  "user_scripts_folder": "Scripts",
  "enable_folder_templates": true,
  "folder_templates": [
    {
      "folder": "01-Inbox",
      "template": "Templates/Daily Note.md"
    },
    {
      "folder": "02-Projects", 
      "template": "Templates/Project.md"
    }
  ],
  "syntax_highlighting": true,
  "enabled_templates_hotkeys": [""],
  "startup_templates": [""]
}
EOF

echo -e "${GREEN}   ✅ Plugin configurations created${NC}"

echo ""
echo -e "${BLUE}Step 4.10: Final Integration Validation${NC}"
echo "-------------------------------------"

# Validation checks
VALIDATION_SUCCESS=true

# Check Obsidian installation
if [ -d "/Applications/Obsidian.app" ]; then
    echo -e "${GREEN}   ✅ Obsidian Application: Installed${NC}"
else
    echo -e "${RED}   ❌ Obsidian Application: Not found${NC}"
    VALIDATION_SUCCESS=false
fi

# Check vault structure
if [ -d "$VAULT_PATH" ]; then
    echo -e "${GREEN}   ✅ Vault Structure: Created${NC}"
    
    # Count directories
    DIR_COUNT=$(find "$VAULT_PATH" -maxdepth 1 -type d | wc -l)
    echo -e "${GREEN}   ✅ Vault Directories: $((DIR_COUNT - 1)) created${NC}"
else
    echo -e "${RED}   ❌ Vault Structure: Missing${NC}"
    VALIDATION_SUCCESS=false
fi

# Check Obsidian configuration
if [ -d "$OBSIDIAN_CONFIG_DIR" ]; then
    echo -e "${GREEN}   ✅ Obsidian Configuration: Created${NC}"
else
    echo -e "${RED}   ❌ Obsidian Configuration: Missing${NC}"
    VALIDATION_SUCCESS=false
fi

# Check integration script
if [ -x "$INTEGRATION_SCRIPT" ]; then
    echo -e "${GREEN}   ✅ Integration Script: Available${NC}"
else
    echo -e "${RED}   ❌ Integration Script: Missing${NC}"
    VALIDATION_SUCCESS=false
fi

# Check templates
TEMPLATE_COUNT=$(find "$VAULT_PATH/Templates" -name "*.md" 2>/dev/null | wc -l)
if [ "$TEMPLATE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Templates: $TEMPLATE_COUNT created${NC}"
else
    echo -e "${YELLOW}   ⚠️  Templates: Limited${NC}"
fi

# Check sample content
CONTENT_COUNT=$(find "$VAULT_PATH" -name "*.md" -not -path "*/Templates/*" 2>/dev/null | wc -l)
if [ "$CONTENT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Sample Content: $CONTENT_COUNT files${NC}"
else
    echo -e "${YELLOW}   ⚠️  Sample Content: Limited${NC}"
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
    "next_step_name": "Final Configuration & Testing",
    "validation_success": true,
    "obsidian_ready": true,
    "vault_created": true,
    "integration_available": true
}
EOF
    
    echo ""
    echo "🎯 Obsidian Vault Integration Complete!"
    echo "📋 Integration Summary:"
    echo "   • Obsidian application installed"
    echo "   • SefirotVault created with organized structure"
    echo "   • Essential plugins configured"
    echo "   • Templates and sample content provided"
    echo "   • ChromaDB integration script ready"
    echo "   • Automated sync available"
    echo ""
    echo "🚀 Ready for Step 5: Final Configuration & Testing"
    echo ""
    echo -e "${YELLOW}💡 Open Obsidian and navigate to: $VAULT_PATH${NC}"
    echo -e "${YELLOW}💡 Try: obsidian-sync${NC}"
    echo -e "${YELLOW}💡 Read: Welcome to Sefirot.md for usage guide${NC}"
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
    "errors": ["Obsidian integration validation failed"]
}
EOF
    
    echo "Please check the error messages above and retry."
    exit 1
fi