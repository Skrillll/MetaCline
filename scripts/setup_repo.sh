#!/bin/bash

# MetaCline Repository Structure Setup Script
# Purpose: Set up and organize the repository structure
# RICE Score: 48.0 (High Priority)

# Source common functions if they exist
if [ -f "scripts/common.sh" ]; then
    source scripts/common.sh
else
    # Color codes for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    # Logging functions
    log_info() { echo -e "${BLUE}ℹ️ INFO:${NC} $1"; }
    log_success() { echo -e "${GREEN}✅ SUCCESS:${NC} $1"; }
    log_warning() { echo -e "${YELLOW}⚠️ WARNING:${NC} $1"; }
    log_error() { echo -e "${RED}❌ ERROR:${NC} $1"; }
fi

# Error handling
handle_error() {
    log_error "$1"
    exit 1
}

# Check if we're in the project root
if [ ! -f "package.json" ]; then
    handle_error "This script must be run from the project root directory"
fi

# Clean up backup files
cleanup_backups() {
    log_info "Cleaning up backup files..."
    find . -name "*.backup_*" -type f -delete
    find . -name "*.back-up" -type f -delete
}

# Create necessary directories
create_directories() {
    log_info "Creating directory structure..."
    
    # Core application directories
    mkdir -p src/{core,api,services,utils,shared,integrations}/{__tests__,types}
    
    # Documentation directories
    mkdir -p docs/{api,architecture,development,deployment}
    
    # Configuration directories
    mkdir -p config/{development,production,test}
    
    # Build and deployment directories
    mkdir -p scripts/{build,deploy,ci}
    
    # Test directories
    mkdir -p tests/{unit,integration,e2e}
    
    # MetaCline specific directories
    mkdir -p src/core/{ai-engine,safety-controls,meta-programming}
    mkdir -p src/core/ai-engine/{prompts,models,validators}
    mkdir -p src/core/safety-controls/{rate-limiting,output-validation}
    mkdir -p src/core/meta-programming/{engine,templates}
    
    log_success "Directory structure created"
}

# Create necessary files
create_files() {
    log_info "Creating necessary files..."
    
    # Create README files
    echo "# MetaCline Core" > src/core/README.md
    echo "Core functionality for MetaCline's AI capabilities." >> src/core/README.md
    
    echo "# MetaCline API" > src/api/README.md
    echo "API endpoints and interface definitions." >> src/api/README.md
    
    echo "# MetaCline Services" > src/services/README.md
    echo "Service layer implementations." >> src/services/README.md
    
    # Create configuration templates
    echo '{"development": true}' > config/development/config.json
    echo '{"production": true}' > config/production/config.json
    echo '{"test": true}' > config/test/config.json
    
    # Create documentation index files
    echo "# MetaCline Documentation" > docs/README.md
    echo "# API Documentation" > docs/api/README.md
    echo "# Architecture Documentation" > docs/architecture/README.md
    echo "# Development Guide" > docs/development/README.md
    echo "# Deployment Guide" > docs/deployment/README.md
    
    log_success "Files created"
}

# Update .gitignore
update_gitignore() {
    log_info "Updating .gitignore..."
    
    cat >> .gitignore << EOF

# MetaCline specific
.core-setup-complete
*.backup_*
*.back-up
config/development/local.json
config/production/secrets.json

# Build directories
dist/
build/
coverage/

# Dependency directories
node_modules/
.pnpm-store/

# Environment files
.env
.env.local
.env.*

# IDE files
.idea/
*.swp
*.swo
.DS_Store

# Debug logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
debug.log

# Test coverage
coverage/
.nyc_output/

# Temporary files
*.tmp
*.temp
EOF
    
    log_success ".gitignore updated"
}

# Main execution
log_info "Starting repository structure setup..."

# Execute setup steps
cleanup_backups
create_directories
create_files
update_gitignore

# Create setup completion marker
echo "Repository structure setup completed: $(date '+%Y-%m-%d %H:%M:%S')" > .repo-setup-complete

log_success "Repository structure setup complete!"
log_info "Next steps:"
echo "1. Review the created directory structure"
echo "2. Add specific README files for each component"
echo "3. Configure development environment settings" 