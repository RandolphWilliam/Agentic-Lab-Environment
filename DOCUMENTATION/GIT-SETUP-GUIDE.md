# Git Setup Guide for First-Time Users

## Installing Git on macOS

### Option 1: Install via Homebrew (Recommended)
If you have Homebrew installed:
```bash
brew install git
```

### Option 2: Install via Xcode Command Line Tools
```bash
xcode-select --install
```
This will prompt you to install developer tools including git.

### Option 3: Download from Git Website
Visit [git-scm.com](https://git-scm.com/download/mac) and download the installer.

## Initial Git Configuration

Before using git, configure your identity:

```bash
# Set your name (this will appear in commits)
git config --global user.name "Your Full Name"

# Set your email (use your GitHub email)
git config --global user.email "your.email@example.com"

# Set default branch name to 'main'
git config --global init.defaultBranch main

# Verify configuration
git config --list
```

## Creating a GitHub Account

1. Go to [github.com](https://github.com)
2. Click "Sign up"
3. Choose a username (this will be part of your repository URL)
4. Use the same email you configured in git above

## Creating Your First Repository on GitHub

1. **Login to GitHub**
2. **Click the "+" icon** in the top-right corner
3. **Select "New repository"**
4. **Repository settings**:
   - **Name**: `sefirot-intelligence-platform`
   - **Description**: `Open-source AI knowledge management software for privacy-focused professionals`
   - **Visibility**: Public (to attract contributors)
   - **Initialize**: Leave unchecked (we'll upload existing code)

5. **Click "Create repository"**

## Publishing Sefirot to GitHub

### Step 1: Navigate to Your Project
```bash
cd "/path/to/your/Agentic-Lab-Environment"
```

### Step 2: Initialize Git Repository
```bash
# Initialize git in the project folder
git init

# Add all files to git tracking
git add .

# Check what files will be committed (optional)
git status
```

### Step 3: Create Initial Commit
```bash
# Create your first commit with all the project files
git commit -m "Initial release of Sefirot Intelligence Platform

- Complete Electron GUI installer with professional branding
- ChromaDB intelligence engine with 3-tier privacy framework  
- Obsidian integration with custom vault structure
- Hardware-adaptive performance for Apple Silicon and Intel
- Comprehensive documentation and troubleshooting guides"
```

### Step 4: Connect to GitHub Repository
Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username:

```bash
# Add GitHub repository as remote origin
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/sefirot-intelligence-platform.git

# Set the main branch
git branch -M main

# Push your code to GitHub
git push -u origin main
```

## What Happens Next

After running these commands:

1. **Your code will be live on GitHub** at `https://github.com/YOUR_USERNAME/sefirot-intelligence-platform`
2. **People can discover your project** through GitHub's search and recommendations
3. **Users can report issues** using the issue templates we created
4. **Developers can contribute** using the contributing guidelines
5. **You can track engagement** with stars, forks, and discussions

## Common Git Commands for Ongoing Development

### Making Changes and Updates
```bash
# See what files you've changed
git status

# Add specific files
git add filename.js

# Add all changed files
git add .

# Commit your changes
git commit -m "Describe what you changed"

# Push changes to GitHub
git push
```

### Staying Organized
```bash
# Create a new branch for a feature
git checkout -b feature-name

# Switch between branches
git checkout main
git checkout feature-name

# Merge a feature branch back to main
git checkout main
git merge feature-name
```

## Security Best Practices

### What NOT to Commit
Your `.gitignore` file already protects you, but be aware:
- **Never commit API keys** or credentials
- **Never commit user data** from SefirotVault
- **Never commit large binary files** unnecessarily

### Checking Before You Commit
```bash
# Always review what you're about to commit
git diff

# See which files are staged for commit
git status
```

## GitHub Repository Settings

After publishing, configure your repository:

### 1. Enable Discussions
- Go to your repository on GitHub
- Click "Settings" tab
- Scroll to "Features" section
- Check "Discussions"

### 2. Add Topics
- Click the gear icon next to "About" on your repository page
- Add topics: `ai`, `privacy`, `knowledge-management`, `local-first`, `macos`, `chromadb`, `electron`

### 3. Create Release
- Click "Releases" on the right sidebar
- Click "Create a new release"
- Tag: `v1.0.0`
- Title: `Sefirot Intelligence Platform v1.0 - Initial Release`
- Description: Copy from your README highlights

## Troubleshooting Common Issues

### "Permission denied" when pushing
You may need to authenticate with GitHub:
```bash
# If you have 2FA enabled, you need a personal access token
# Go to GitHub → Settings → Developer settings → Personal access tokens
# Create a token with 'repo' permissions
# Use the token as your password when prompted
```

### "Repository not found"
Double-check:
- Repository name matches exactly
- Your username is correct in the URL
- Repository exists and is public/you have access

### "Nothing to commit"
This means no files have changed since your last commit:
```bash
# Check status
git status

# If you want to commit anyway (empty commit)
git commit --allow-empty -m "Trigger rebuild"
```

## Getting Your First Contributors

### 1. Share in Relevant Communities
- Reddit: r/MacOS, r/programming, r/privacy
- Hacker News: Submit as "Show HN: [project]"
- AI/ML communities interested in local-first tools

### 2. Engage with Similar Projects
- Star and watch related repositories
- Comment thoughtfully on issues in similar projects
- Follow developers working on privacy-focused AI tools

### 3. Document Everything
- Keep your README updated with new features
- Respond quickly to issues and questions
- Write blog posts or tutorials about your approach

---

**Next Steps**: After publishing to GitHub, monitor the repository's Insights tab to track visitors, clones, and engagement. This will help you understand what resonates with potential users and contributors.