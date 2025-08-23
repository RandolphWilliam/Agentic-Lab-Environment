{
  description = "Sefirot ChromaDB Intelligence Platform v2.0 - Production Ready";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mamba-nixpkgs.url = "github:mamba-org/mamba/main";
  };

  outputs = { self, nixpkgs, flake-utils, mamba-nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Python packages for ChromaDB Intelligence Platform
        pythonEnv = pkgs.python311.withPackages (ps: with ps; [
          # Core vector database and AI components
          chromadb
          sentence-transformers
          transformers
          torch
          numpy
          pandas
          scikit-learn
          faiss
          
          # Document processing (Docling integration)
          pypdf2
          python-docx
          pillow
          pytesseract
          beautifulsoup4
          lxml
          markdown
          
          # NLP processing pipeline
          spacy
          nltk
          gensim
          
          # Graph analysis for Obsidian integration
          networkx
          igraph
          
          # System monitoring and hardware profiling
          psutil
          py-cpuinfo
          
          # Data handling and storage
          sqlalchemy
          aiosqlite
          pydantic
          
          # Web services and API integration
          requests
          aiohttp
          fastapi
          uvicorn
          
          # Configuration and settings management
          pyyaml
          toml
          click
          
          # Development and testing
          pytest
          black
          flake8
          mypy
          
          # Progress monitoring and logging
          tqdm
          rich
          loguru
        ]);
        
        # System packages for document processing and hardware optimization
        systemPackages = with pkgs; [
          # Document processing tools
          poppler_utils  # PDF utilities
          tesseract      # OCR
          imagemagick    # Image processing
          pandoc         # Document conversion
          
          # Hardware monitoring and optimization
          htop
          nvtop          # GPU monitoring
          lshw           # Hardware detection
          
          # Development tools
          git
          curl
          wget
          jq
          
          # Performance optimization
          parallel       # Parallel processing
          
          # Obsidian integration tools
          ripgrep        # Fast text search
          fd             # Fast file finder
          
          # Service integration tools
          awscli2        # AWS services
          google-cloud-sdk  # Google Cloud services
        ];
        
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pythonEnv ] ++ systemPackages;
          
          # v1.78.8 Production Environment with Privacy & Semantic Intelligence
          shellHook = ''
            echo "🌳 Sefirot ChromaDB Intelligence Platform v2.0"
            echo "  Multi-Vault Semantic Processing: ✅"
            echo "  Privacy Classification (3-Tier): ✅" 
            echo "  Semantic Tagging (47 Categories): ✅"
            echo "  Hardware Optimization: ✅"
            echo ""
            echo "Python: $(python --version)"
            echo "ChromaDB: $(python -c 'import chromadb; print(chromadb.__version__)' 2>/dev/null || echo 'Installing...')"
            echo ""
            
            # Set optimization flags for different hardware configurations
            export OMP_NUM_THREADS=$(nproc)
            export TOKENIZERS_PARALLELISM=false  # Avoid transformer warnings
            export PYTHONPATH="$PWD:$PYTHONPATH"
            
            # Hardware-specific optimizations
            if [ -f "/proc/cpuinfo" ]; then
              CPU_INFO=$(cat /proc/cpuinfo | grep "model name" | head -1)
              echo "CPU: $CPU_INFO"
            fi
            
            # GPU detection and optimization
            if command -v nvidia-smi &> /dev/null; then
              echo "NVIDIA GPU detected - CUDA acceleration available"
              export CUDA_VISIBLE_DEVICES="0"
            fi
            
            # AMD GPU detection (for 5700G)
            if lspci | grep -i amd | grep -i vga &> /dev/null; then
              echo "AMD GPU detected - OpenCL acceleration may be available"
              export ROC_VISIBLE_DEVICES="0"
            fi
            
            # Memory optimization based on available RAM
            TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
            TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
            echo "System RAM: ${TOTAL_RAM_GB}GB"
            
            if [ $TOTAL_RAM_GB -gt 16 ]; then
              echo "High memory system - enabling large batch processing"
              export CHROMADB_BATCH_SIZE=1000
            else
              echo "Standard memory system - conservative batch processing"
              export CHROMADB_BATCH_SIZE=100
            fi
            
            echo ""
            echo "🔧 Sefirot Intelligence Commands Available:"
            echo "  - sefirot init                    # Initialize user configuration"
            echo "  - sefirot sync [vault_path]       # Process and index vault content"
            echo "  - sefirot query 'search term'     # Semantic search across collections"
            echo "  - sefirot privacy-scan [path]     # Classify content privacy tiers"
            echo "  - sefirot tag-analysis [path]     # Apply semantic tags"
            echo "  - sefirot doctor                  # System health check"
            echo "  - sefirot hardware-profile        # Generate hardware optimization"
            echo ""
            echo "📖 Documentation: docs.sefirot.ai"
            echo "💬 Community: discord.gg/sefirot" 
            echo ""
          '';
          
          # Production-ready environment variables (user-configurable)
          SEFIROT_HOME = "$HOME/.sefirot";
          SEFIROT_CONFIG = "$HOME/.sefirot/user_config.yaml";
          CHROMADB_DATA_PATH = "$HOME/.sefirot/chromadb_data";
          SEFIROT_LOGS = "$HOME/.sefirot/logs";
          
          # Privacy and processing settings
          PRIVACY_CLASSIFICATION_ENABLED = "true";
          SEMANTIC_TAGGING_ENABLED = "true";
          MULTI_VAULT_PROCESSING = "true";
          
          # V2+ Conda transition preparation
          CONDA_ENV_PATH = "./environment.yml";
          FUTURE_MAMBA_READY = "true";
        };
        
        # Production environment (optimized for deployment)
        devShells.production = pkgs.mkShell {
          buildInputs = [ pythonEnv ] ++ (with pkgs; [
            # Minimal production dependencies
            git
            curl
            htop
            parallel
          ]);
          
          shellHook = ''
            echo "🏭 ChromaDB Platform - Production Environment"
            export PYTHONPATH="$PWD:$PYTHONPATH"
            export CHROMADB_PRODUCTION=true
            export CHROMADB_TELEMETRY=false
            echo "Production optimizations enabled"
          '';
        };
        
        # Testing environment (includes additional testing tools)
        devShells.testing = pkgs.mkShell {
          buildInputs = [ pythonEnv ] ++ systemPackages ++ (with pkgs; [
            # Additional testing tools
            valgrind       # Memory debugging
            gdb            # Debugging
            strace         # System call tracing
          ]);
          
          shellHook = ''
            echo "🧪 ChromaDB Platform - Testing Environment"
            export PYTHONPATH="$PWD:$PYTHONPATH"
            export CHROMADB_TEST_MODE=true
            export PYTEST_ARGS="--verbose --capture=no"
            echo "Testing tools and debugging enabled"
          '';
        };
        
        # Production-ready Sefirot CLI package
        packages.default = pkgs.writeShellScriptBin "sefirot" ''
          echo "🌳 Sefirot ChromaDB Intelligence Platform v2.0"
          echo ""
          echo "Available environments:"
          echo "  nix develop                    # Full development environment"
          echo "  nix develop .#production       # Production deployment"
          echo "  nix develop .#testing          # Testing and validation"
          echo ""
          echo "First-time setup:"
          echo "  1. Copy user_config_template.yaml to ~/.sefirot/user_config.yaml"
          echo "  2. Edit configuration with your vault paths and API keys"
          echo "  3. Run: nix develop"
          echo "  4. Initialize: sefirot init"
          echo ""
          echo "V2+ Conda Migration:"
          echo "  conda env create -f environment.yml"
          echo "  conda activate sefirot-v2"
          echo ""
          echo "Hardware Detection:"
          python -c "import platform; print(f'System: {platform.system()} {platform.machine()}')"
          
          if command -v nvidia-smi &> /dev/null; then
            echo "CUDA GPUs:"
            nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits
          fi
          
          echo ""
          echo "📖 Full documentation: https://docs.sefirot.ai"
          echo "🚀 Ready for first 10 test users!"
        '';
      }
    );
}