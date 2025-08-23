# Google Takeout Import Workflow

**Import Google account data directly into Sefirot Intelligence Platform for comprehensive semantic search and analysis.**

## Overview

Google Takeout provides a complete export of your Google account data including Gmail, Drive documents, Photos metadata, Chrome history, and Google Assistant interactions. This workflow processes that exported data through Sefirot's privacy-first intelligence engine for powerful local semantic search.

## Data Security Approach

All processing occurs locally on your Mac. Google Takeout data remains under your complete control with Sefirot's 3-tier privacy classification automatically applied:

- **Personal emails and private documents**: Tier 3 (local processing only)
- **Business communications**: Tier 2 (limited cloud AI with user consent) 
- **Public information**: Tier 1 (full AI processing enabled)

## Step-by-Step Import Process

### 1. Request Google Takeout Export

1. Navigate to [takeout.google.com](https://takeout.google.com)
2. Select data types for export:
   - **Gmail** (all messages and labels)
   - **Drive** (documents, spreadsheets, presentations)
   - **Photos** (metadata and EXIF data for organization)
   - **Chrome** (browsing history and bookmarks)
   - **YouTube** (watch history, playlists, subscriptions)
   - **Maps** (saved locations, timeline)
3. Choose export format: **ZIP files, 10GB maximum per file**
4. Select delivery method: **Send download link via email**
5. Request export and await Google's processing completion

### 2. Download and Prepare Archive

```bash
# Create dedicated import directory
mkdir -p ~/Documents/sefirot-imports/google-takeout
cd ~/Documents/sefirot-imports/google-takeout

# Download all ZIP files from Google's provided links
# Files typically named: takeout-YYYYMMDD-HHMMSS.zip

# Verify download integrity
ls -la *.zip
```

### 3. Extract and Organize Data

```bash
# Extract all archives
for zip_file in *.zip; do
    unzip "$zip_file" -d extracted/
done

# Verify extraction
ls -la extracted/Takeout/
```

### 4. Configure Privacy Settings

Before processing, review the sample privacy configuration:

```yaml
# google-takeout-privacy.yaml
privacy_rules:
  gmail:
    default_tier: "personal"
    exceptions:
      - pattern: "@company-domain.com"
        tier: "business"
      - pattern: "newsletter|notification"
        tier: "public"
  
  drive:
    default_tier: "personal"
    exceptions:
      - pattern: "shared|public"
        tier: "business"
      - pattern: "resume|cv|public-profile"
        tier: "public"
  
  chrome:
    default_tier: "personal"
    exceptions:
      - pattern: "stackoverflow.com|github.com|documentation"
        tier: "public"
```

### 5. Execute Import Process

```bash
# Navigate to Sefirot installation directory
cd ~/agentic-lab-environment

# Run Google Takeout import with privacy configuration
python CORE-PLATFORM/chromadb_intelligence_engine.py \
  --import-source google-takeout \
  --data-path ~/Documents/sefirot-imports/google-takeout/extracted/Takeout \
  --privacy-config ~/Documents/sefirot-imports/google-takeout/google-takeout-privacy.yaml \
  --batch-size 100 \
  --progress-reporting verbose
```

### 6. Verification and Testing

```bash
# Verify import completion
python -c "
import chromadb
client = chromadb.PersistentClient(path='./chromadb-storage')
collections = client.list_collections()
print(f'Available collections: {[c.name for c in collections]}')

# Test semantic search
gmail_collection = client.get_collection('gmail')
results = gmail_collection.query(
    query_texts=['project deadlines'],
    n_results=5
)
print(f'Found {len(results[\"documents\"][0])} relevant emails')
"
```

## Supported Data Types and Processing

### Gmail Processing
- **Email content**: Full-text semantic search across message bodies
- **Metadata extraction**: Sender/recipient networks, timestamp analysis
- **Attachment handling**: PDF, DOC, image text extraction
- **Label preservation**: Google labels mapped to Sefirot categories

### Google Drive Processing
- **Document formats**: Docs, Sheets, Slides, PDFs converted to searchable text
- **Version history**: Latest versions processed, edit history preserved
- **Sharing metadata**: Collaboration patterns and access levels recorded
- **Folder structure**: Hierarchical organization maintained

### Chrome Data Processing
- **Browsing history**: URL titles and visit patterns for research context
- **Bookmarks**: Organized categories with semantic clustering
- **Search history**: Query patterns for knowledge domain identification

### Photos Metadata Processing
- **EXIF data**: Location, timestamp, camera settings for contextual search
- **Image recognition**: Optional local AI analysis for content tagging
- **Album organization**: Google Photos albums preserved as semantic clusters

## Performance and Storage Considerations

**Typical Processing Times** (Apple M1 MacBook Pro, 16GB RAM):
- Gmail (10,000 emails): 15-20 minutes
- Drive documents (1,000 files): 25-30 minutes  
- Chrome history (50,000 entries): 10-15 minutes
- Photos metadata (10,000 images): 5-10 minutes

**Storage Requirements**:
- Original Google Takeout: 2-50GB depending on data volume
- Processed ChromaDB vectors: 10-20% of original size
- Temporary processing space: 2x original data size

## Privacy and Security Implementation

### Local Processing Guarantees
- All Google data processing occurs on your Mac
- No data transmitted to external services during import
- ChromaDB storage encrypted with FileVault system encryption
- API keys for optional cloud services stored in macOS keychain

### Privacy Tier Assignment
- **Automatic classification**: Pattern matching against common privacy indicators
- **User review interface**: Confirm privacy assignments before processing
- **Granular control**: Override automatic classifications per document/email
- **Audit logging**: Complete record of privacy decisions and data handling

## Troubleshooting Common Issues

### Large Archive Processing
```bash
# For archives larger than 10GB, process in segments
python CORE-PLATFORM/chromadb_intelligence_engine.py \
  --import-source google-takeout \
  --data-path ~/Documents/sefirot-imports/google-takeout/extracted/Takeout \
  --segment-processing gmail \
  --memory-limit 8GB
```

### Encoding Issues with International Content
```bash
# Force UTF-8 encoding for international character support
export PYTHONIOENCODING=utf-8
python CORE-PLATFORM/chromadb_intelligence_engine.py [import-command]
```

### Rate Limiting for Large Email Collections
```bash
# Reduce processing speed to prevent memory issues
python CORE-PLATFORM/chromadb_intelligence_engine.py \
  --import-source google-takeout \
  --data-path [path] \
  --batch-size 50 \
  --processing-delay 0.1
```

## Integration with Obsidian Knowledge Management

After successful import, Google Takeout data integrates seamlessly with Obsidian:

- **Smart notes creation**: Automatic note generation for important emails/documents
- **Link generation**: Bi-directional links between related content across Google services
- **Dashboard creation**: Overview notes summarizing import results and key findings
- **Search integration**: Obsidian search enhanced with ChromaDB semantic capabilities

## Expected Results

Upon completion, you'll have:

1. **Comprehensive semantic search** across all Google account data
2. **Privacy-classified content** ready for secure AI processing
3. **Obsidian integration** with automatic knowledge graph creation
4. **Local intelligence platform** with complete control over your Google data
5. **Cross-service insights** revealing patterns across Gmail, Drive, Chrome, and Photos

This import transforms years of Google account activity into a privacy-controlled, locally-processed intelligence platform optimized for knowledge work and personal productivity enhancement.