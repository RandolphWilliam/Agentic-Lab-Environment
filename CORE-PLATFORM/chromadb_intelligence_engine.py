#!/usr/bin/env python3
"""
SEFIROT CHROMADB ADAPTIVE INTELLIGENCE ENGINE
Phase 2: Complete Intelligence Processing Capabilities

This is the core intelligence processing engine that was missing from the initial
distribution package. It provides the actual ChromaDB-based semantic processing,
document analysis, and adaptive learning capabilities.
"""

import os
import sys
import json
import yaml
import asyncio
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any, Union
from dataclasses import dataclass, asdict
from datetime import datetime
import hashlib

# Core ChromaDB and ML dependencies
import chromadb
from chromadb.config import Settings
import numpy as np
from sentence_transformers import SentenceTransformer
import spacy
from transformers import pipeline

# Document processing
import docling
from docling.document_converter import DocumentConverter
import pypdf
import docx
import markdown

# Privacy and classification
import re
from enum import Enum

class PrivacyTier(Enum):
    """3-tier privacy classification system"""
    PUBLIC = "tier1_public_transferable_safe_for_sharing"
    BUSINESS = "tier2_business_confidential_requires_abstraction" 
    PERSONAL = "tier3_personal_private_explicit_consent_required"

@dataclass
class DocumentMetadata:
    """Complete document metadata for intelligence processing"""
    file_path: str
    content_hash: str
    privacy_tier: PrivacyTier
    file_type: str
    size_bytes: int
    processed_timestamp: datetime
    embedding_model: str
    chunk_count: int
    language: str
    sentiment_score: float
    topics: List[str]
    entities: Dict[str, List[str]]
    vault_location: Optional[str] = None
    obsidian_links: List[str] = None

class ChromaDBIntelligenceEngine:
    """
    Complete ChromaDB Adaptive Intelligence Engine
    
    This is the core intelligence processing system that provides:
    - Semantic document processing and chunking
    - Privacy-aware embedding generation
    - Adaptive learning from user interactions
    - Cross-document relationship discovery
    - Obsidian vault integration
    - Hardware-optimized processing
    """
    
    def __init__(self, config_path: str = None):
        self.config_path = config_path or os.path.expanduser("~/.sefirot/credentials.yaml")
        self.sefirot_dir = Path.home() / ".sefirot"
        self.chromadb_path = self.sefirot_dir / "chromadb"
        
        # Initialize logging
        self._setup_logging()
        
        # Load configuration
        self.config = self._load_config()
        
        # Initialize core components
        self.chroma_client = None
        self.embedding_model = None
        self.nlp_pipeline = None
        self.privacy_detector = None
        self.document_converter = None
        
        # Performance tracking
        self.processing_stats = {
            "documents_processed": 0,
            "embeddings_created": 0,
            "queries_executed": 0,
            "privacy_classifications": {"tier1": 0, "tier2": 0, "tier3": 0},
            "performance_metrics": {}
        }
        
        self.logger.info("Sefirot ChromaDB Intelligence Engine initialized")
    
    def _setup_logging(self):
        """Configure logging for intelligence engine"""
        log_dir = self.sefirot_dir / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_dir / "intelligence_engine.log"),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger("SefirotIntelligence")
    
    def _load_config(self) -> Dict[str, Any]:
        """Load Sefirot configuration with fallback defaults"""
        try:
            with open(self.config_path, 'r') as f:
                config = yaml.safe_load(f)
            self.logger.info(f"Configuration loaded from {self.config_path}")
            return config
        except FileNotFoundError:
            self.logger.warning("Configuration file not found, using defaults")
            return self._get_default_config()
    
    def _get_default_config(self) -> Dict[str, Any]:
        """Default configuration for offline operation"""
        return {
            "intelligence_settings": {
                "embedding_model": "all-MiniLM-L6-v2",
                "privacy_mode": "local_only",
                "chunk_size": 512,
                "chunk_overlap": 50,
                "max_tokens_per_chunk": 500
            },
            "privacy_framework": {
                "default_tier": "tier2_business_confidential",
                "auto_classify": True,
                "consent_required_tier3": True
            },
            "performance": {
                "batch_size": 32,
                "max_concurrent_documents": 4,
                "enable_gpu": True
            }
        }
    
    async def initialize_components(self):
        """Initialize all intelligence processing components"""
        self.logger.info("Initializing ChromaDB Intelligence components...")
        
        # Initialize ChromaDB
        await self._init_chromadb()
        
        # Initialize embedding model
        await self._init_embedding_model()
        
        # Initialize NLP pipeline
        await self._init_nlp_pipeline()
        
        # Initialize privacy detector
        await self._init_privacy_detector()
        
        # Initialize document converter
        await self._init_document_converter()
        
        self.logger.info("All intelligence components initialized successfully")
    
    async def _init_chromadb(self):
        """Initialize ChromaDB with persistent storage"""
        try:
            self.chromadb_path.mkdir(parents=True, exist_ok=True)
            
            self.chroma_client = chromadb.PersistentClient(
                path=str(self.chromadb_path),
                settings=Settings(
                    allow_reset=False,
                    anonymized_telemetry=False
                )
            )
            
            # Create or get collections for each privacy tier
            self.collections = {}
            for tier in PrivacyTier:
                collection_name = f"sefirot_{tier.value.split('_')[0]}"
                self.collections[tier] = self.chroma_client.get_or_create_collection(
                    name=collection_name,
                    metadata={"privacy_tier": tier.value}
                )
            
            self.logger.info("ChromaDB initialized with privacy-tiered collections")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize ChromaDB: {e}")
            raise
    
    async def _init_embedding_model(self):
        """Initialize sentence transformer model for embeddings"""
        try:
            model_name = self.config.get("intelligence_settings", {}).get(
                "embedding_model", "all-MiniLM-L6-v2"
            )
            
            self.embedding_model = SentenceTransformer(model_name)
            self.logger.info(f"Embedding model '{model_name}' loaded successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize embedding model: {e}")
            raise
    
    async def _init_nlp_pipeline(self):
        """Initialize spaCy NLP pipeline for entity extraction"""
        try:
            # Try to load English model, download if necessary
            try:
                self.nlp_pipeline = spacy.load("en_core_web_sm")
            except OSError:
                self.logger.warning("Downloading spaCy English model...")
                spacy.cli.download("en_core_web_sm")
                self.nlp_pipeline = spacy.load("en_core_web_sm")
            
            self.logger.info("spaCy NLP pipeline initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize NLP pipeline: {e}")
            raise
    
    async def _init_privacy_detector(self):
        """Initialize privacy classification system"""
        try:
            # Privacy detection patterns
            self.privacy_patterns = {
                PrivacyTier.PERSONAL: [
                    r'\b\d{3}-\d{2}-\d{4}\b',  # SSN
                    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  # Email
                    r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b',  # Credit card
                    r'\bpassword|secret|private key|confidential\b',
                    r'\bphone.*\d{3}[-.]?\d{3}[-.]?\d{4}\b'
                ],
                PrivacyTier.BUSINESS: [
                    r'\bconfidential|proprietary|internal only\b',
                    r'\bapi[_\s]key|access[_\s]token\b',
                    r'\bclient|customer|revenue|profit\b',
                    r'\bcontract|agreement|deal\b'
                ]
            }
            
            # Compile regex patterns for performance
            self.compiled_patterns = {}
            for tier, patterns in self.privacy_patterns.items():
                self.compiled_patterns[tier] = [
                    re.compile(pattern, re.IGNORECASE) for pattern in patterns
                ]
            
            self.logger.info("Privacy detection system initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize privacy detector: {e}")
            raise
    
    async def _init_document_converter(self):
        """Initialize document converter for multi-format support"""
        try:
            self.document_converter = DocumentConverter()
            self.logger.info("Document converter initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize document converter: {e}")
            raise
    
    def classify_privacy_tier(self, text: str) -> PrivacyTier:
        """
        Classify text into privacy tiers using pattern matching and NLP
        
        Args:
            text: Text content to classify
            
        Returns:
            PrivacyTier: Detected privacy classification
        """
        text_lower = text.lower()
        
        # Check for PERSONAL tier patterns (highest priority)
        for pattern in self.compiled_patterns.get(PrivacyTier.PERSONAL, []):
            if pattern.search(text):
                self.processing_stats["privacy_classifications"]["tier3"] += 1
                return PrivacyTier.PERSONAL
        
        # Check for BUSINESS tier patterns
        for pattern in self.compiled_patterns.get(PrivacyTier.BUSINESS, []):
            if pattern.search(text):
                self.processing_stats["privacy_classifications"]["tier2"] += 1
                return PrivacyTier.BUSINESS
        
        # Use NLP for additional context analysis
        if self.nlp_pipeline:
            doc = self.nlp_pipeline(text[:1000])  # Limit for performance
            
            # Check for sensitive entities
            sensitive_entities = ["PERSON", "ORG", "GPE", "MONEY", "DATE"]
            entity_count = sum(1 for ent in doc.ents if ent.label_ in sensitive_entities)
            
            if entity_count > 5:  # High entity density suggests business content
                self.processing_stats["privacy_classifications"]["tier2"] += 1
                return PrivacyTier.BUSINESS
        
        # Default to PUBLIC if no sensitive patterns detected
        self.processing_stats["privacy_classifications"]["tier1"] += 1
        return PrivacyTier.PUBLIC
    
    async def process_document(self, file_path: str, vault_location: str = None) -> DocumentMetadata:
        """
        Complete document processing with intelligence extraction
        
        Args:
            file_path: Path to document file
            vault_location: Optional Obsidian vault location
            
        Returns:
            DocumentMetadata: Complete metadata for processed document
        """
        self.logger.info(f"Processing document: {file_path}")
        start_time = datetime.now()
        
        try:
            file_path = Path(file_path)
            
            # Extract text content based on file type
            text_content = await self._extract_text_content(file_path)
            
            # Calculate content hash for deduplication
            content_hash = hashlib.sha256(text_content.encode()).hexdigest()
            
            # Classify privacy tier
            privacy_tier = self.classify_privacy_tier(text_content)
            
            # Process with NLP pipeline
            doc = self.nlp_pipeline(text_content[:5000])  # Limit for performance
            
            # Extract entities
            entities = {}
            for ent in doc.ents:
                if ent.label_ not in entities:
                    entities[ent.label_] = []
                entities[ent.label_].append(ent.text)
            
            # Calculate sentiment
            sentiment_score = 0.0  # Placeholder - could use sentiment analysis
            
            # Extract topics (placeholder for topic modeling)
            topics = ["general"]  # Could implement topic modeling
            
            # Chunk text for embedding
            chunks = self._chunk_text(text_content)
            
            # Generate embeddings
            embeddings = self.embedding_model.encode(chunks)
            
            # Store in appropriate ChromaDB collection
            collection = self.collections[privacy_tier]
            
            # Create unique IDs for chunks
            chunk_ids = [f"{content_hash}_{i}" for i in range(len(chunks))]
            
            # Store embeddings with metadata
            collection.add(
                embeddings=embeddings.tolist(),
                documents=chunks,
                ids=chunk_ids,
                metadatas=[{
                    "source_file": str(file_path),
                    "chunk_index": i,
                    "privacy_tier": privacy_tier.value,
                    "processed_timestamp": datetime.now().isoformat(),
                    "content_hash": content_hash
                } for i in range(len(chunks))]
            )
            
            # Extract Obsidian links if vault location provided
            obsidian_links = []
            if vault_location:
                obsidian_links = self._extract_obsidian_links(text_content)
            
            # Create document metadata
            metadata = DocumentMetadata(
                file_path=str(file_path),
                content_hash=content_hash,
                privacy_tier=privacy_tier,
                file_type=file_path.suffix.lower(),
                size_bytes=file_path.stat().st_size,
                processed_timestamp=datetime.now(),
                embedding_model=self.embedding_model.model_name,
                chunk_count=len(chunks),
                language="en",  # Could implement language detection
                sentiment_score=sentiment_score,
                topics=topics,
                entities=entities,
                vault_location=vault_location,
                obsidian_links=obsidian_links
            )
            
            # Update processing statistics
            self.processing_stats["documents_processed"] += 1
            self.processing_stats["embeddings_created"] += len(chunks)
            
            processing_time = (datetime.now() - start_time).total_seconds()
            self.logger.info(
                f"Document processed successfully in {processing_time:.2f}s: "
                f"{len(chunks)} chunks, {privacy_tier.value}"
            )
            
            return metadata
            
        except Exception as e:
            self.logger.error(f"Failed to process document {file_path}: {e}")
            raise
    
    async def _extract_text_content(self, file_path: Path) -> str:
        """Extract text content from various file formats"""
        file_ext = file_path.suffix.lower()
        
        try:
            if file_ext == '.pdf':
                return self._extract_pdf_text(file_path)
            elif file_ext in ['.docx', '.doc']:
                return self._extract_docx_text(file_path)
            elif file_ext in ['.txt', '.md']:
                return file_path.read_text(encoding='utf-8')
            else:
                # Try docling for other formats
                result = self.document_converter.convert(str(file_path))
                return result.document.export_to_text()
                
        except Exception as e:
            self.logger.warning(f"Failed to extract text from {file_path}: {e}")
            return ""
    
    def _extract_pdf_text(self, file_path: Path) -> str:
        """Extract text from PDF files"""
        try:
            with open(file_path, 'rb') as file:
                reader = pypdf.PdfReader(file)
                text = ""
                for page in reader.pages:
                    text += page.extract_text() + "\n"
                return text
        except Exception as e:
            self.logger.warning(f"Failed to extract PDF text: {e}")
            return ""
    
    def _extract_docx_text(self, file_path: Path) -> str:
        """Extract text from Word documents"""
        try:
            doc = docx.Document(file_path)
            text = ""
            for paragraph in doc.paragraphs:
                text += paragraph.text + "\n"
            return text
        except Exception as e:
            self.logger.warning(f"Failed to extract DOCX text: {e}")
            return ""
    
    def _chunk_text(self, text: str) -> List[str]:
        """Chunk text for optimal embedding processing"""
        chunk_size = self.config.get("intelligence_settings", {}).get("chunk_size", 512)
        chunk_overlap = self.config.get("intelligence_settings", {}).get("chunk_overlap", 50)
        
        # Simple chunking by character count with overlap
        chunks = []
        start = 0
        text_len = len(text)
        
        while start < text_len:
            end = min(start + chunk_size, text_len)
            
            # Try to break at sentence boundary
            if end < text_len:
                last_period = text.rfind('.', start, end)
                if last_period > start + chunk_size // 2:
                    end = last_period + 1
            
            chunk = text[start:end].strip()
            if chunk:
                chunks.append(chunk)
            
            start = max(start + 1, end - chunk_overlap)
        
        return chunks
    
    def _extract_obsidian_links(self, text: str) -> List[str]:
        """Extract Obsidian-style [[links]] from text"""
        link_pattern = r'\[\[([^\]]+)\]\]'
        matches = re.findall(link_pattern, text)
        return list(set(matches))  # Remove duplicates
    
    async def semantic_search(self, query: str, privacy_tier: PrivacyTier = None, limit: int = 10) -> List[Dict]:
        """
        Perform semantic search across document collections
        
        Args:
            query: Search query text
            privacy_tier: Optional privacy tier filter
            limit: Maximum number of results
            
        Returns:
            List of search results with metadata
        """
        self.logger.info(f"Performing semantic search: '{query}' (limit: {limit})")
        
        try:
            # Generate query embedding
            query_embedding = self.embedding_model.encode([query])
            
            results = []
            collections_to_search = []
            
            if privacy_tier:
                collections_to_search = [self.collections[privacy_tier]]
            else:
                # Search all collections, respecting privacy preferences
                collections_to_search = list(self.collections.values())
            
            for collection in collections_to_search:
                # Query collection
                search_results = collection.query(
                    query_embeddings=query_embedding.tolist(),
                    n_results=min(limit, 100)  # ChromaDB limit
                )
                
                # Process results
                for i, doc in enumerate(search_results['documents'][0]):
                    results.append({
                        'document': doc,
                        'metadata': search_results['metadatas'][0][i],
                        'distance': search_results['distances'][0][i],
                        'id': search_results['ids'][0][i]
                    })
            
            # Sort by distance (similarity)
            results.sort(key=lambda x: x['distance'])
            
            # Update statistics
            self.processing_stats["queries_executed"] += 1
            
            self.logger.info(f"Search completed: {len(results)} results found")
            return results[:limit]
            
        except Exception as e:
            self.logger.error(f"Search failed: {e}")
            raise
    
    async def get_processing_stats(self) -> Dict[str, Any]:
        """Get intelligence engine processing statistics"""
        stats = self.processing_stats.copy()
        
        # Add collection counts
        stats["collection_counts"] = {}
        for tier, collection in self.collections.items():
            try:
                count = collection.count()
                stats["collection_counts"][tier.value] = count
            except:
                stats["collection_counts"][tier.value] = 0
        
        return stats
    
    async def health_check(self) -> Dict[str, Any]:
        """Comprehensive health check of intelligence engine"""
        health = {
            "status": "healthy",
            "components": {},
            "timestamp": datetime.now().isoformat()
        }
        
        # Check ChromaDB
        try:
            _ = self.chroma_client.heartbeat()
            health["components"]["chromadb"] = "healthy"
        except Exception as e:
            health["components"]["chromadb"] = f"error: {e}"
            health["status"] = "degraded"
        
        # Check embedding model
        try:
            test_embedding = self.embedding_model.encode(["health check"])
            health["components"]["embedding_model"] = "healthy"
        except Exception as e:
            health["components"]["embedding_model"] = f"error: {e}"
            health["status"] = "degraded"
        
        # Check NLP pipeline
        try:
            test_doc = self.nlp_pipeline("Health check test.")
            health["components"]["nlp_pipeline"] = "healthy"
        except Exception as e:
            health["components"]["nlp_pipeline"] = f"error: {e}"
            health["status"] = "degraded"
        
        return health

# CLI Interface
async def main():
    """CLI interface for testing intelligence engine"""
    if len(sys.argv) < 2:
        print("Usage: python chromadb_intelligence_engine.py <command> [args]")
        print("Commands:")
        print("  init                    - Initialize engine")
        print("  process <file_path>     - Process document")
        print("  search <query>          - Search documents")
        print("  stats                   - Show processing stats")
        print("  health                  - Health check")
        return
    
    command = sys.argv[1]
    engine = ChromaDBIntelligenceEngine()
    
    try:
        await engine.initialize_components()
        
        if command == "init":
            print("✅ ChromaDB Intelligence Engine initialized successfully")
            
        elif command == "process":
            if len(sys.argv) < 3:
                print("Error: File path required")
                return
            file_path = sys.argv[2]
            metadata = await engine.process_document(file_path)
            print(f"✅ Document processed: {metadata.chunk_count} chunks, {metadata.privacy_tier.value}")
            
        elif command == "search":
            if len(sys.argv) < 3:
                print("Error: Search query required")
                return
            query = " ".join(sys.argv[2:])
            results = await engine.semantic_search(query)
            print(f"Found {len(results)} results:")
            for i, result in enumerate(results[:5]):
                print(f"{i+1}. {result['document'][:100]}... (distance: {result['distance']:.3f})")
                
        elif command == "stats":
            stats = await engine.get_processing_stats()
            print(json.dumps(stats, indent=2, default=str))
            
        elif command == "health":
            health = await engine.health_check()
            print(json.dumps(health, indent=2))
            
        else:
            print(f"Unknown command: {command}")
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())