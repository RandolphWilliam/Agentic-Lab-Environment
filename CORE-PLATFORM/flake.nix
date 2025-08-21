{
  description = "ChromaDB Adaptive Intelligence Platform - Development Environment";

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
          
          # Hardware optimization environment variables
          shellHook = ''
            echo "🚀 ChromaDB Adaptive Intelligence Platform Environment"
            echo "Python: $(python --version)"
            echo "ChromaDB: Available"
            echo "Hardware Profiling: Enabled"
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
            echo "Environment ready for ChromaDB development!"
            echo "Available commands:"
            echo "  - python hardware_profiler.py  # Profile system capabilities"
            echo "  - python chromadb_setup.py     # Initialize ChromaDB collections"
            echo "  - python document_processor.py # Process documents for embedding"
            echo ""
          '';
          
          # Additional environment variables for development
          CHROMADB_DATA_PATH = "./chromadb_data";
          OBSIDIAN_VAULT_PATH = "/Users/randolphsanford/Claude laptop/Claude Obsidian Vault v1/Claude Collab vault and working space";
          PRIVACY_CONFIG_PATH = "./privacy_settings.yaml";
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
        
        # Cross-platform compatibility
        packages.default = pkgs.writeShellScriptBin "chromadb-platform" ''
          echo "ChromaDB Adaptive Intelligence Platform"
          echo "Usage:"
          echo "  nix develop                    # Enter development environment"
          echo "  nix develop .#production      # Enter production environment"  
          echo "  nix develop .#testing         # Enter testing environment"
          echo ""
          echo "Hardware Detection:"
          python -c "import platform; print(f'System: {platform.system()} {platform.machine()}')"
          
          if command -v nvidia-smi &> /dev/null; then
            echo "CUDA GPUs:"
            nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits
          fi
        '';
      }
    );
}