#!/bin/bash
# SEFIROT SEQUENCED INSTALLATION - STEP 2: Python Environment & Dependencies
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
echo "║                        STEP 2: Python Environment & Dependencies           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# GUI Integration Support
STEP_NUMBER=2
STEP_NAME="Python Environment & Dependencies"
STEP_DESCRIPTION="Setting up Python 3.11 environment with AI/ML dependencies"

# Export step information for GUI wrapper
export SEFIROT_CURRENT_STEP=$STEP_NUMBER
export SEFIROT_CURRENT_STEP_NAME="$STEP_NAME"
export SEFIROT_CURRENT_STEP_DESCRIPTION="$STEP_DESCRIPTION"

echo -e "${GREEN}STEP $STEP_NUMBER: $STEP_NAME${NC}"
echo "Description: $STEP_DESCRIPTION"
echo "================================================="
echo ""

# Check prerequisites
SEFIROT_INSTALL_DIR="$HOME/.sefirot/installation"
mkdir -p "$SEFIROT_INSTALL_DIR"

# Verify Step 1 completed
if [ ! -f "$SEFIROT_INSTALL_DIR/step_1_status.txt" ] || ! grep -q "completed" "$SEFIROT_INSTALL_DIR/step_1_status.txt"; then
    echo -e "${RED}❌ Step 1 (Environment Setup) must be completed first${NC}"
    echo "Please run step_01_environment_setup.sh first."
    exit 1
fi

# Mark step as started
echo "started:$(date -Iseconds)" > "$SEFIROT_INSTALL_DIR/step_${STEP_NUMBER}_status.txt"

# Ensure we have conda/mamba available
export PATH="$HOME/miniforge3/bin:$PATH"
if command -v conda &> /dev/null; then
    eval "$(conda shell.bash hook)"
fi

echo -e "${BLUE}Step 2.1: Creating Sefirot Conda Environment${NC}"
echo "--------------------------------------------"

# Create dedicated conda environment for Sefirot
ENV_NAME="sefirot"
if conda env list | grep -q "^$ENV_NAME "; then
    echo -e "${YELLOW}   ⚠️  Sefirot environment already exists, recreating...${NC}"
    conda env remove -n "$ENV_NAME" -y > /dev/null 2>&1
fi

echo "   📦 Creating Sefirot conda environment with Python 3.11..."
conda create -n "$ENV_NAME" python=3.11 -y > /dev/null 2>&1
echo -e "${GREEN}   ✅ Sefirot conda environment created${NC}"

# Activate environment
echo "   🔄 Activating Sefirot environment..."
conda activate "$ENV_NAME"
echo -e "${GREEN}   ✅ Sefirot environment activated${NC}"

echo ""
echo -e "${BLUE}Step 2.2: Installing Core Python Dependencies${NC}"
echo "---------------------------------------------"

# Essential Python packages
CORE_PACKAGES=(
    "pip>=23.0"
    "setuptools>=65.0"
    "wheel"
    "numpy>=1.24.0"
    "pandas>=2.0.0"
    "pyyaml>=6.0"
    "requests>=2.28.0"
    "aiohttp>=3.8.0"
    "python-dotenv>=1.0.0"
    "click>=8.0.0"
    "rich>=13.0.0"
    "typer>=0.9.0"
)

for package in "${CORE_PACKAGES[@]}"; do
    echo "   📦 Installing $package..."
    conda install -n "$ENV_NAME" "$package" -c conda-forge -y > /dev/null 2>&1
    echo -e "${GREEN}   ✅ $package installed${NC}"
done

echo ""
echo -e "${BLUE}Step 2.3: Installing ChromaDB and Vector Database Dependencies${NC}"
echo "-------------------------------------------------------------"

# ChromaDB and vector database packages
VECTOR_PACKAGES=(
    "chromadb>=0.4.15"
    "sentence-transformers>=2.2.0"
    "transformers>=4.30.0"
    "torch>=2.0.0"
    "faiss-cpu>=1.7.0"
    "pinecone-client>=2.2.0"
    "hnswlib>=0.7.0"
)

for package in "${VECTOR_PACKAGES[@]}"; do
    echo "   📦 Installing $package..."
    if [[ "$package" == chromadb* ]]; then
        # ChromaDB needs to be installed via pip
        conda run -n "$ENV_NAME" pip install "$package" > /dev/null 2>&1
    else
        conda install -n "$ENV_NAME" "$package" -c conda-forge -c pytorch -y > /dev/null 2>&1
    fi
    echo -e "${GREEN}   ✅ $package installed${NC}"
done

echo ""
echo -e "${BLUE}Step 2.4: Installing NLP and Language Processing Dependencies${NC}"
echo "------------------------------------------------------------"

# NLP packages
NLP_PACKAGES=(
    "spacy>=3.6.0"
    "nltk>=3.8.0"
    "textstat>=0.7.0"
    "langdetect>=1.0.9"
    "beautifulsoup4>=4.12.0"
    "markdown>=3.4.0"
    "python-docx>=0.8.11"
    "pypdf>=3.15.0"
    "docling>=1.0.0"
)

for package in "${NLP_PACKAGES[@]}"; do
    echo "   📦 Installing $package..."
    if [[ "$package" == docling* ]]; then
        # Docling might need pip installation
        conda run -n "$ENV_NAME" pip install "$package" > /dev/null 2>&1
    else
        conda install -n "$ENV_NAME" "$package" -c conda-forge -y > /dev/null 2>&1
    fi
    echo -e "${GREEN}   ✅ $package installed${NC}"
done

# Download spaCy English model
echo "   📦 Downloading spaCy English language model..."
conda run -n "$ENV_NAME" python -m spacy download en_core_web_sm > /dev/null 2>&1
echo -e "${GREEN}   ✅ spaCy English model downloaded${NC}"

echo ""
echo -e "${BLUE}Step 2.5: Installing Development and Jupyter Dependencies${NC}"
echo "--------------------------------------------------------"

# Development tools
DEV_PACKAGES=(
    "jupyter>=1.0.0"
    "jupyterlab>=4.0.0"
    "ipywidgets>=8.0.0"
    "matplotlib>=3.7.0"
    "seaborn>=0.12.0"
    "plotly>=5.15.0"
    "black>=23.0.0"
    "flake8>=6.0.0"
    "pytest>=7.4.0"
    "pytest-asyncio>=0.21.0"
)

for package in "${DEV_PACKAGES[@]}"; do
    echo "   📦 Installing $package..."
    conda install -n "$ENV_NAME" "$package" -c conda-forge -y > /dev/null 2>&1
    echo -e "${GREEN}   ✅ $package installed${NC}"
done

echo ""
echo -e "${BLUE}Step 2.6: Installing Obsidian Integration Dependencies${NC}"
echo "------------------------------------------------------"

# Obsidian and note-taking integration
OBSIDIAN_PACKAGES=(
    "watchdog>=3.0.0"
    "markdown-extensions>=0.1.0"
    "python-frontmatter>=1.0.0"
    "gitpython>=3.1.0"
)

for package in "${OBSIDIAN_PACKAGES[@]}"; do
    echo "   📦 Installing $package..."
    conda run -n "$ENV_NAME" pip install "$package" > /dev/null 2>&1
    echo -e "${GREEN}   ✅ $package installed${NC}"
done

echo ""
echo -e "${BLUE}Step 2.7: Installing API Client Dependencies${NC}"
echo "--------------------------------------------"

# API clients for various services
API_PACKAGES=(
    "anthropic>=0.25.0"
    "openai>=1.35.0"
    "shopify-python-api>=12.0.0"
    "runpod>=1.4.0"
    "gradio>=4.0.0"
    "streamlit>=1.28.0"
)

for package in "${API_PACKAGES[@]}"; do
    echo "   📦 Installing $package..."
    conda run -n "$ENV_NAME" pip install "$package" > /dev/null 2>&1
    echo -e "${GREEN}   ✅ $package installed${NC}"
done

echo ""
echo -e "${BLUE}Step 2.8: Hardware-Specific Optimizations${NC}"
echo "--------------------------------------------"

# Detect hardware for optimizations
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo "   🔧 Detected Apple Silicon - installing optimized packages..."
    
    # Apple Silicon specific packages
    APPLE_SILICON_PACKAGES=(
        "tensorflow-macos>=2.13.0"
        "tensorflow-metal>=1.0.0"
    )
    
    for package in "${APPLE_SILICON_PACKAGES[@]}"; do
        echo "   📦 Installing $package..."
        conda run -n "$ENV_NAME" pip install "$package" > /dev/null 2>&1 || echo -e "${YELLOW}   ⚠️  Optional package $package skipped${NC}"
    done
    
    echo -e "${GREEN}   ✅ Apple Silicon optimizations applied${NC}"
else
    echo "   🔧 Detected Intel Mac - using standard packages"
    echo -e "${GREEN}   ✅ Intel optimizations applied${NC}"
fi

echo ""
echo -e "${BLUE}Step 2.9: Creating Python Environment Configuration${NC}"
echo "--------------------------------------------------"

# Create Python environment configuration
PYTHON_CONFIG_FILE="$HOME/.sefirot/python_environment.yaml"

cat > "$PYTHON_CONFIG_FILE" << EOF
python_environment:
  conda_environment_name: "$ENV_NAME"
  python_version: "$(conda run -n $ENV_NAME python --version | cut -d' ' -f2)"
  environment_path: "$(conda info --envs | grep $ENV_NAME | awk '{print $2}')"
  created_at: "$(date -Iseconds)"
  
core_packages:
  chromadb: "$(conda run -n $ENV_NAME python -c "import chromadb; print(chromadb.__version__)" 2>/dev/null || echo 'not installed')"
  sentence_transformers: "$(conda run -n $ENV_NAME python -c "import sentence_transformers; print(sentence_transformers.__version__)" 2>/dev/null || echo 'not installed')"
  transformers: "$(conda run -n $ENV_NAME python -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo 'not installed')"
  spacy: "$(conda run -n $ENV_NAME python -c "import spacy; print(spacy.__version__)" 2>/dev/null || echo 'not installed')"
  
hardware_optimizations:
  architecture: "$ARCH"
  apple_silicon_optimized: $([ "$ARCH" == "arm64" ] && echo "true" || echo "false")
  tensorflow_metal: $([ "$ARCH" == "arm64" ] && echo "enabled" || echo "disabled")

activation_commands:
  conda_activate: "conda activate $ENV_NAME"
  environment_ready: true
EOF

echo -e "${GREEN}   ✅ Python environment configuration saved${NC}"

# Create activation script
ACTIVATION_SCRIPT="$HOME/.sefirot/activate_python.sh"

cat > "$ACTIVATION_SCRIPT" << EOF
#!/bin/bash
# Sefirot Python Environment Activation Script

# Ensure conda is available
export PATH="\$HOME/miniforge3/bin:\$PATH"
eval "\$(conda shell.bash hook)"

# Activate Sefirot environment
conda activate $ENV_NAME

# Set environment variables
export SEFIROT_PYTHON_ENV="$ENV_NAME"
export PYTHONPATH="\$HOME/.sefirot/CORE-PLATFORM:\$PYTHONPATH"

# Verify environment
echo "🐍 Sefirot Python Environment Active"
echo "   Python: \$(python --version)"
echo "   Environment: \$CONDA_DEFAULT_ENV"
echo "   ChromaDB: \$(python -c 'import chromadb; print(chromadb.__version__)' 2>/dev/null || echo 'Not available')"
EOF

chmod +x "$ACTIVATION_SCRIPT"
echo -e "${GREEN}   ✅ Python activation script created${NC}"

echo ""
echo -e "${BLUE}Step 2.10: Environment Validation${NC}"
echo "--------------------------------"

# Validate Python environment
VALIDATION_SUCCESS=true

# Test Python version
PYTHON_VERSION=$(conda run -n "$ENV_NAME" python --version 2>&1)
if [[ "$PYTHON_VERSION" == *"3.11"* ]]; then
    echo -e "${GREEN}   ✅ Python: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}   ❌ Python: Wrong version ($PYTHON_VERSION)${NC}"
    VALIDATION_SUCCESS=false
fi

# Test core imports
CORE_IMPORTS=(
    "chromadb"
    "sentence_transformers"
    "transformers"
    "spacy"
    "numpy"
    "pandas"
)

for import_name in "${CORE_IMPORTS[@]}"; do
    if conda run -n "$ENV_NAME" python -c "import $import_name" 2>/dev/null; then
        VERSION=$(conda run -n "$ENV_NAME" python -c "import $import_name; print(getattr($import_name, '__version__', 'unknown'))" 2>/dev/null)
        echo -e "${GREEN}   ✅ $import_name: $VERSION${NC}"
    else
        echo -e "${RED}   ❌ $import_name: Import failed${NC}"
        VALIDATION_SUCCESS=false
    fi
done

# Test spaCy English model
if conda run -n "$ENV_NAME" python -c "import spacy; nlp = spacy.load('en_core_web_sm'); print('OK')" > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ spaCy English model: Available${NC}"
else
    echo -e "${RED}   ❌ spaCy English model: Not available${NC}"
    VALIDATION_SUCCESS=false
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
    "next_step_name": "ChromaDB Intelligence Platform",
    "validation_success": true,
    "python_environment_ready": true,
    "conda_environment": "$ENV_NAME"
}
EOF
    
    echo ""
    echo "🎯 Python Environment Setup Complete!"
    echo "📋 Environment Summary:"
    echo "   • Python 3.11 conda environment: '$ENV_NAME'"
    echo "   • ChromaDB vector database ready"
    echo "   • Sentence transformers for embeddings"
    echo "   • spaCy NLP pipeline with English model"
    echo "   • Hardware-optimized packages installed"
    echo "   • API clients configured"
    echo ""
    echo "🚀 Ready for Step 3: ChromaDB Intelligence Platform"
    echo ""
    echo -e "${YELLOW}💡 To activate Python environment: source $ACTIVATION_SCRIPT${NC}"
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
    "errors": ["Python environment validation failed"]
}
EOF
    
    echo "Please check the error messages above and retry."
    exit 1
fi