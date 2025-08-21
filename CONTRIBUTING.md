# Contributing to Sefirot Intelligence Platform

Thanks for your interest in contributing! This project started as internal tooling and has evolved into a comprehensive platform that addresses the privacy and security needs of professionals who require local-first AI capabilities.

## Before You Contribute

1. **Use the platform first** - Install it, use it for at least a week, understand what it does well and where it breaks
2. **Check existing issues** - Someone might already be working on what you have in mind
3. **Start small** - Bug fixes and small improvements are easier to review than major features

## Types of Contributions We Need

### High Priority
- **Installation issues** - Different macOS versions, hardware configurations, edge cases
- **Performance optimizations** - Memory usage, processing speed, battery life
- **Document classification improvements** - Better privacy tier detection
- **Error handling** - Graceful failures, recovery mechanisms

### Medium Priority  
- **Additional document types** - Better support for specific file formats
- **UI/UX improvements** - Installer flow, progress indicators, error messages
- **Documentation** - Clearer setup instructions, troubleshooting guides
- **Testing** - Automated tests for core functionality

### Lower Priority
- **New AI integrations** - Additional API providers
- **Feature additions** - New capabilities beyond core functionality
- **Platform support** - Linux, Windows (significant effort required)

## Development Setup

### Quick Setup
```bash
git clone https://github.com/sefirotconsulting/sefirot-intelligence-platform
cd sefirot-intelligence-platform
npm install

# For Python development
conda create -n sefirot-dev python=3.11
conda activate sefirot-dev
pip install -r requirements-dev.txt
```

### Testing Your Changes
```bash
# Test the installer
npm start

# Test individual components  
./SEQUENCED-INSTALLATION/step_01_environment_setup.sh
python CORE-PLATFORM/chromadb_intelligence_engine.py --test

# Run diagnostic suite
sefirot doctor
```

## Submitting Issues

### Bug Reports
Include:
- **macOS version** and hardware (Intel vs Apple Silicon)
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Log output** (use `sefirot logs --tail 100`)
- **System info** (use `sefirot export-diagnostics`)

### Feature Requests
Before submitting:
- **Check if it fits** the core mission (local-first, privacy-focused)
- **Explain the use case** - what problem does this solve?
- **Consider complexity** - is this worth the maintenance burden?

## Pull Request Process

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b fix-installation-issue`)
3. **Make focused changes** - one issue per PR
4. **Test thoroughly** - especially on different hardware
5. **Update documentation** if needed
6. **Write a clear PR description** explaining what and why

### Code Style
- **Python**: Follow existing patterns, use type hints where helpful
- **JavaScript**: ES6+, no unnecessary complexity
- **Shell scripts**: POSIX-compatible, error handling
- **Documentation**: Clear, concise, example-heavy

## What We're NOT Looking For

- **Cloud-first solutions** - defeats the core privacy purpose
- **Complex frameworks** - keep dependencies minimal
- **Platform bloat** - this should remain focused on local AI + knowledge management
- **Breaking changes** - maintain backward compatibility where possible

## Review Process

- **Initial response**: Within a few days
- **Review timeline**: 1-2 weeks depending on complexity
- **Feedback**: We'll ask questions, suggest changes, test on different systems
- **Merge criteria**: Works well, doesn't break existing functionality, fits project goals

## Community Guidelines

- **Be respectful** - we're all trying to build something useful
- **Be patient** - this is maintained by a small team
- **Be specific** - vague issues and PRs are hard to act on
- **Be understanding** - sometimes we'll say no to good ideas if they don't fit

## Recognition

Contributors who meaningfully improve the project will be:
- **Listed in CONTRIBUTORS.md**
- **Mentioned in release notes**
- **Given credit in relevant documentation**

## Questions?

- **General questions**: GitHub Discussions
- **Development questions**: GitHub Issues with `question` label
- **Private inquiries**: hello@sefirot.dev

---

*This project exists because existing tools didn't meet our requirements for privacy-focused AI knowledge management. If you're contributing, you likely share our vision for local-first AI capabilities. Let's build something better together.*