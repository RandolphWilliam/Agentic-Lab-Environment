#!/usr/bin/env python3
"""
SEFIROT VAULT TRANSPLANTATION SYSTEM
Complete environment migration with privacy cleaning

This system handles the complete transplantation of your Obsidian vault,
ChromaDB collections, and entire development environment while respecting
privacy boundaries and cleaning sensitive data.
"""

import os
import sys
import json
import yaml
import asyncio
import shutil
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any, Set
from dataclasses import dataclass, asdict
from datetime import datetime
import hashlib
import re
import zipfile
import tempfile

# Privacy and file processing
from chromadb_intelligence_engine import PrivacyTier, ChromaDBIntelligenceEngine

@dataclass
class VaultTransplantationConfig:
    """Configuration for vault transplantation process"""
    source_vault_path: str
    target_vault_path: str
    obsidian_config_path: str
    include_plugins: bool = True
    privacy_cleaning_enabled: bool = True
    preserve_vault_structure: bool = True
    migrate_attachments: bool = True
    create_backup: bool = True
    privacy_tier_limits: List[PrivacyTier] = None

@dataclass 
class TransplantationReport:
    """Report of vault transplantation process"""
    total_files_processed: int
    files_migrated: int
    files_privacy_cleaned: int
    files_excluded: int
    privacy_tier_counts: Dict[str, int]
    obsidian_plugins_migrated: List[str]
    chromadb_collections_migrated: int
    errors_encountered: List[str]
    processing_time_seconds: float
    backup_location: Optional[str]

class VaultTransplantationSystem:
    """
    Complete vault transplantation system for Sefirot environment migration
    
    This system provides:
    - Complete Obsidian vault migration with structure preservation
    - Privacy-aware content cleaning and filtering
    - ChromaDB collection transplantation
    - Custom plugin configuration transfer
    - Development environment replication
    - Backup and rollback capabilities
    """
    
    def __init__(self, config: VaultTransplantationConfig):
        self.config = config
        self.sefirot_dir = Path.home() / ".sefirot"
        self.intelligence_engine = None
        
        # Initialize logging
        self._setup_logging()
        
        # Privacy patterns for cleaning
        self.privacy_cleaning_patterns = {
            'personal_identifiers': [
                r'\b\d{3}-\d{2}-\d{4}\b',  # SSN
                r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  # Email addresses
                r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b',  # Credit card numbers
                r'\b\+?1?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}\b',  # Phone numbers
            ],
            'api_credentials': [
                r'\b[Aa]pi[_\s]?[Kk]ey\s*[=:]\s*["\']?[\w\-]+["\']?',
                r'\b[Aa]ccess[_\s]?[Tt]oken\s*[=:]\s*["\']?[\w\-]+["\']?',
                r'\b[Ss]ecret[_\s]?[Kk]ey\s*[=:]\s*["\']?[\w\-]+["\']?',
                r'\bsk-[a-zA-Z0-9]{20,}',  # OpenAI style keys
                r'\bant-[a-zA-Z0-9]{20,}',  # Anthropic style keys
            ],
            'private_conversations': [
                r'claude:|assistant:|human:|user:',  # Conversation markers
                r'```[\s\S]*?```',  # Code blocks that might contain conversations
                r'<conversation>[\s\S]*?</conversation>',  # Conversation blocks
            ]
        }
        
        # Compile patterns for performance
        self.compiled_patterns = {}
        for category, patterns in self.privacy_cleaning_patterns.items():
            self.compiled_patterns[category] = [
                re.compile(pattern, re.IGNORECASE | re.MULTILINE) 
                for pattern in patterns
            ]
        
        self.logger.info("Vault Transplantation System initialized")
    
    def _setup_logging(self):
        """Configure logging for transplantation system"""
        log_dir = self.sefirot_dir / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_dir / "vault_transplantation.log"),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger("SefirotVaultTransplant")
    
    async def initialize_intelligence_engine(self):
        """Initialize ChromaDB intelligence engine for privacy classification"""
        try:
            self.intelligence_engine = ChromaDBIntelligenceEngine()
            await self.intelligence_engine.initialize_components()
            self.logger.info("Intelligence engine initialized for privacy classification")
        except Exception as e:
            self.logger.warning(f"Intelligence engine initialization failed: {e}")
            self.intelligence_engine = None
    
    async def perform_complete_transplantation(self) -> TransplantationReport:
        """
        Perform complete vault and environment transplantation
        
        Returns:
            TransplantationReport: Detailed report of transplantation process
        """
        self.logger.info("Starting complete vault transplantation")
        start_time = datetime.now()
        
        report = TransplantationReport(
            total_files_processed=0,
            files_migrated=0,
            files_privacy_cleaned=0,
            files_excluded=0,
            privacy_tier_counts={"tier1": 0, "tier2": 0, "tier3": 0},
            obsidian_plugins_migrated=[],
            chromadb_collections_migrated=0,
            errors_encountered=[],
            processing_time_seconds=0.0,
            backup_location=None
        )
        
        try:
            # Step 1: Create backup if requested
            if self.config.create_backup:
                backup_location = await self._create_backup()
                report.backup_location = backup_location
                self.logger.info(f"Backup created at: {backup_location}")
            
            # Step 2: Initialize intelligence engine for privacy classification
            await self.initialize_intelligence_engine()
            
            # Step 3: Analyze source vault structure
            vault_structure = await self._analyze_vault_structure()
            self.logger.info(f"Analyzed vault structure: {len(vault_structure['files'])} files")
            
            # Step 4: Process and migrate vault files
            migration_results = await self._migrate_vault_files(vault_structure)
            report.total_files_processed = migration_results['total_processed']
            report.files_migrated = migration_results['migrated']
            report.files_privacy_cleaned = migration_results['privacy_cleaned']
            report.files_excluded = migration_results['excluded']
            report.privacy_tier_counts = migration_results['privacy_tier_counts']
            
            # Step 5: Migrate Obsidian configuration and plugins
            plugin_results = await self._migrate_obsidian_plugins()
            report.obsidian_plugins_migrated = plugin_results['migrated_plugins']
            
            # Step 6: Transplant ChromaDB collections
            chromadb_results = await self._transplant_chromadb_collections()
            report.chromadb_collections_migrated = chromadb_results['collections_migrated']
            
            # Step 7: Create transplanted environment configuration
            await self._create_transplanted_environment_config()
            
            # Step 8: Validate transplanted environment
            validation_results = await self._validate_transplanted_environment()
            if not validation_results['success']:
                report.errors_encountered.extend(validation_results['errors'])
            
            processing_time = (datetime.now() - start_time).total_seconds()
            report.processing_time_seconds = processing_time
            
            self.logger.info(
                f"Vault transplantation completed in {processing_time:.2f}s: "
                f"{report.files_migrated} files migrated, "
                f"{report.files_privacy_cleaned} files privacy cleaned"
            )
            
            return report
            
        except Exception as e:
            self.logger.error(f"Vault transplantation failed: {e}")
            report.errors_encountered.append(str(e))
            raise
    
    async def _create_backup(self) -> str:
        """Create backup of source vault and environment"""
        backup_dir = self.sefirot_dir / "backups" / f"vault_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        # Backup vault
        if Path(self.config.source_vault_path).exists():
            vault_backup_path = backup_dir / "vault"
            shutil.copytree(self.config.source_vault_path, vault_backup_path)
            self.logger.info(f"Vault backed up to: {vault_backup_path}")
        
        # Backup Obsidian config
        if Path(self.config.obsidian_config_path).exists():
            obsidian_backup_path = backup_dir / "obsidian_config"
            shutil.copytree(self.config.obsidian_config_path, obsidian_backup_path)
            self.logger.info(f"Obsidian config backed up to: {obsidian_backup_path}")
        
        # Backup Sefirot configuration
        if self.sefirot_dir.exists():
            sefirot_backup_path = backup_dir / "sefirot_config"
            shutil.copytree(self.sefirot_dir, sefirot_backup_path, 
                           ignore=shutil.ignore_patterns('chromadb', 'logs', 'backups'))
            self.logger.info(f"Sefirot config backed up to: {sefirot_backup_path}")
        
        return str(backup_dir)
    
    async def _analyze_vault_structure(self) -> Dict[str, Any]:
        """Analyze source vault structure and file inventory"""
        vault_path = Path(self.config.source_vault_path)
        
        if not vault_path.exists():
            raise ValueError(f"Source vault path does not exist: {vault_path}")
        
        structure = {
            'root_path': str(vault_path),
            'files': [],
            'directories': [],
            'file_types': {},
            'total_size_bytes': 0,
            'obsidian_links': set(),
            'attachments': []
        }
        
        # Walk through vault directory
        for file_path in vault_path.rglob('*'):
            if file_path.is_file():
                # Skip Obsidian system files
                if any(skip in str(file_path) for skip in ['.obsidian', '.trash', '.DS_Store']):
                    continue
                
                file_info = {
                    'path': str(file_path),
                    'relative_path': str(file_path.relative_to(vault_path)),
                    'size_bytes': file_path.stat().st_size,
                    'extension': file_path.suffix.lower(),
                    'modified_time': datetime.fromtimestamp(file_path.stat().st_mtime)
                }
                
                structure['files'].append(file_info)
                structure['total_size_bytes'] += file_info['size_bytes']
                
                # Track file types
                ext = file_info['extension']
                structure['file_types'][ext] = structure['file_types'].get(ext, 0) + 1
                
                # Extract Obsidian links from markdown files
                if ext == '.md':
                    try:
                        content = file_path.read_text(encoding='utf-8')
                        links = re.findall(r'\[\[([^\]]+)\]\]', content)
                        structure['obsidian_links'].update(links)
                    except Exception as e:
                        self.logger.warning(f"Failed to read {file_path}: {e}")
                
                # Track attachments
                if ext in ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.pdf', '.mp3', '.mp4']:
                    structure['attachments'].append(file_info)
            
            elif file_path.is_dir():
                structure['directories'].append(str(file_path.relative_to(vault_path)))
        
        structure['obsidian_links'] = list(structure['obsidian_links'])
        
        return structure
    
    async def _migrate_vault_files(self, vault_structure: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate vault files with privacy cleaning"""
        target_vault_path = Path(self.config.target_vault_path)
        target_vault_path.mkdir(parents=True, exist_ok=True)
        
        results = {
            'total_processed': len(vault_structure['files']),
            'migrated': 0,
            'privacy_cleaned': 0,
            'excluded': 0,
            'privacy_tier_counts': {"tier1": 0, "tier2": 0, "tier3": 0}
        }
        
        for file_info in vault_structure['files']:
            try:
                source_path = Path(file_info['path'])
                relative_path = file_info['relative_path']
                target_path = target_vault_path / relative_path
                
                # Ensure target directory exists
                target_path.parent.mkdir(parents=True, exist_ok=True)
                
                # Read file content
                if source_path.suffix.lower() in ['.md', '.txt']:
                    # Text files - apply privacy cleaning
                    content = source_path.read_text(encoding='utf-8')
                    
                    # Classify privacy tier
                    privacy_tier = PrivacyTier.PUBLIC
                    if self.intelligence_engine:
                        privacy_tier = self.intelligence_engine.classify_privacy_tier(content)
                    
                    results['privacy_tier_counts'][f"tier{privacy_tier.value.split('_')[0][-1]}"] += 1
                    
                    # Check if file should be excluded based on privacy limits
                    if (self.config.privacy_tier_limits and 
                        privacy_tier not in self.config.privacy_tier_limits):
                        results['excluded'] += 1
                        self.logger.info(f"Excluded {relative_path} (privacy tier: {privacy_tier.value})")
                        continue
                    
                    # Apply privacy cleaning if enabled
                    if self.config.privacy_cleaning_enabled:
                        cleaned_content, was_cleaned = self._clean_content_privacy(content)
                        if was_cleaned:
                            results['privacy_cleaned'] += 1
                            self.logger.info(f"Privacy cleaned: {relative_path}")
                        content = cleaned_content
                    
                    # Write cleaned content
                    target_path.write_text(content, encoding='utf-8')
                    
                else:
                    # Binary files - copy directly
                    shutil.copy2(source_path, target_path)
                
                results['migrated'] += 1
                
            except Exception as e:
                self.logger.error(f"Failed to migrate {file_info['path']}: {e}")
                continue
        
        return results
    
    def _clean_content_privacy(self, content: str) -> Tuple[str, bool]:
        """Clean privacy-sensitive content from text"""
        cleaned_content = content
        was_cleaned = False
        
        for category, patterns in self.compiled_patterns.items():
            for pattern in patterns:
                matches = pattern.findall(cleaned_content)
                if matches:
                    was_cleaned = True
                    if category == 'personal_identifiers':
                        cleaned_content = pattern.sub('[PERSONAL_INFO_REMOVED]', cleaned_content)
                    elif category == 'api_credentials':
                        cleaned_content = pattern.sub('[API_CREDENTIAL_REMOVED]', cleaned_content)
                    elif category == 'private_conversations':
                        cleaned_content = pattern.sub('[CONVERSATION_REMOVED]', cleaned_content)
        
        return cleaned_content, was_cleaned
    
    async def _migrate_obsidian_plugins(self) -> Dict[str, Any]:
        """Migrate Obsidian configuration and custom plugins"""
        results = {
            'migrated_plugins': [],
            'configuration_migrated': False
        }
        
        try:
            obsidian_config_path = Path(self.config.obsidian_config_path)
            
            if not obsidian_config_path.exists():
                self.logger.warning(f"Obsidian config path not found: {obsidian_config_path}")
                return results
            
            target_obsidian_path = Path(self.config.target_vault_path) / '.obsidian'
            
            # Copy entire .obsidian directory
            if target_obsidian_path.exists():
                shutil.rmtree(target_obsidian_path)
            
            shutil.copytree(obsidian_config_path, target_obsidian_path)
            results['configuration_migrated'] = True
            
            # List migrated plugins
            plugins_dir = target_obsidian_path / 'plugins'
            if plugins_dir.exists():
                for plugin_dir in plugins_dir.iterdir():
                    if plugin_dir.is_dir():
                        results['migrated_plugins'].append(plugin_dir.name)
            
            self.logger.info(f"Obsidian configuration migrated: {len(results['migrated_plugins'])} plugins")
            
        except Exception as e:
            self.logger.error(f"Failed to migrate Obsidian configuration: {e}")
        
        return results
    
    async def _transplant_chromadb_collections(self) -> Dict[str, Any]:
        """Transplant ChromaDB collections to target environment"""
        results = {
            'collections_migrated': 0,
            'total_documents_migrated': 0
        }
        
        try:
            source_chromadb_path = self.sefirot_dir / "chromadb"
            target_chromadb_path = Path(self.config.target_vault_path).parent / ".sefirot" / "chromadb"
            
            if source_chromadb_path.exists():
                # Ensure target directory exists
                target_chromadb_path.parent.mkdir(parents=True, exist_ok=True)
                
                if target_chromadb_path.exists():
                    shutil.rmtree(target_chromadb_path)
                
                # Copy ChromaDB directory
                shutil.copytree(source_chromadb_path, target_chromadb_path)
                
                # Count collections (approximate)
                chroma_files = list(target_chromadb_path.rglob('*.sqlite'))
                results['collections_migrated'] = len(chroma_files)
                
                self.logger.info(f"ChromaDB collections transplanted: {results['collections_migrated']}")
            
        except Exception as e:
            self.logger.error(f"Failed to transplant ChromaDB collections: {e}")
        
        return results
    
    async def _create_transplanted_environment_config(self):
        """Create configuration files for transplanted environment"""
        target_sefirot_dir = Path(self.config.target_vault_path).parent / ".sefirot"
        target_sefirot_dir.mkdir(parents=True, exist_ok=True)
        
        # Create transplantation metadata
        transplant_metadata = {
            'transplanted_at': datetime.now().isoformat(),
            'source_vault_path': self.config.source_vault_path,
            'target_vault_path': self.config.target_vault_path,
            'transplantation_config': asdict(self.config),
            'sefirot_version': '1.0'
        }
        
        with open(target_sefirot_dir / 'transplantation_metadata.yaml', 'w') as f:
            yaml.dump(transplant_metadata, f, indent=2)
        
        # Copy main configuration
        if (self.sefirot_dir / 'credentials.yaml').exists():
            shutil.copy2(
                self.sefirot_dir / 'credentials.yaml',
                target_sefirot_dir / 'credentials.yaml'
            )
        
        self.logger.info("Transplanted environment configuration created")
    
    async def _validate_transplanted_environment(self) -> Dict[str, Any]:
        """Validate the transplanted environment"""
        results = {
            'success': True,
            'errors': [],
            'validation_checks': {}
        }
        
        target_vault_path = Path(self.config.target_vault_path)
        target_sefirot_dir = target_vault_path.parent / ".sefirot"
        
        # Check vault directory exists
        if not target_vault_path.exists():
            results['success'] = False
            results['errors'].append("Target vault directory not found")
        else:
            results['validation_checks']['vault_exists'] = True
        
        # Check Obsidian configuration
        obsidian_config_path = target_vault_path / '.obsidian'
        if not obsidian_config_path.exists():
            results['validation_checks']['obsidian_config'] = False
            results['errors'].append("Obsidian configuration not found")
        else:
            results['validation_checks']['obsidian_config'] = True
        
        # Check Sefirot configuration
        if not target_sefirot_dir.exists():
            results['success'] = False
            results['errors'].append("Sefirot configuration directory not found")
        else:
            results['validation_checks']['sefirot_config'] = True
        
        # Check ChromaDB data
        chromadb_path = target_sefirot_dir / 'chromadb'
        if not chromadb_path.exists():
            results['validation_checks']['chromadb_data'] = False
            results['errors'].append("ChromaDB data not found")
        else:
            results['validation_checks']['chromadb_data'] = True
        
        return results

# CLI Interface
async def main():
    """CLI interface for vault transplantation"""
    if len(sys.argv) < 4:
        print("Usage: python vault_transplantation_system.py <source_vault> <target_vault> <obsidian_config>")
        print("Example: python vault_transplantation_system.py ~/Vault ~/NewVault ~/.obsidian")
        return
    
    source_vault = sys.argv[1]
    target_vault = sys.argv[2]
    obsidian_config = sys.argv[3]
    
    config = VaultTransplantationConfig(
        source_vault_path=source_vault,
        target_vault_path=target_vault,
        obsidian_config_path=obsidian_config,
        include_plugins=True,
        privacy_cleaning_enabled=True,
        preserve_vault_structure=True,
        migrate_attachments=True,
        create_backup=True
    )
    
    transplant_system = VaultTransplantationSystem(config)
    
    try:
        print("🚀 Starting vault transplantation...")
        report = await transplant_system.perform_complete_transplantation()
        
        print("\n✅ Vault transplantation completed!")
        print(f"Files processed: {report.total_files_processed}")
        print(f"Files migrated: {report.files_migrated}")
        print(f"Files privacy cleaned: {report.files_privacy_cleaned}")
        print(f"Files excluded: {report.files_excluded}")
        print(f"Obsidian plugins migrated: {len(report.obsidian_plugins_migrated)}")
        print(f"Processing time: {report.processing_time_seconds:.2f}s")
        
        if report.backup_location:
            print(f"Backup created at: {report.backup_location}")
        
        if report.errors_encountered:
            print(f"\n⚠️ Errors encountered: {len(report.errors_encountered)}")
            for error in report.errors_encountered[:5]:
                print(f"  • {error}")
        
    except Exception as e:
        print(f"❌ Transplantation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())