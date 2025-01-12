#!/bin/bash

# MetaCline Core Setup Script
# Purpose: Setup core development environment focusing on Node.js
# RICE Score: 54.0 (Highest Priority)

# Version specifications
NVM_VERSION="v0.39.7"  # Latest stable NVM version
NODE_MIN_VERSION="18.0.0"
NPM_MIN_VERSION="8.0.0"

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

# Version comparison function
version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

# Progress tracking
TOTAL_STEPS=7  # Updated step count
current_step=0

update_progress() {
    current_step=$((current_step + 1))
    log_info "Progress: [$current_step/$TOTAL_STEPS] $1"
}

# Error handling
handle_error() {
    log_error "$1"
    log_info "For troubleshooting, see: docs/performance.md"
    exit 1
}

# Check for required system tools
check_system_dependencies() {
    local missing_deps=()
    for cmd in curl git jq; do
        if ! command -v $cmd >/dev/null 2>&1; then
            missing_deps+=($cmd)
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required system dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and try again"
        exit 1
    fi
}

# Environment validation
validate_environment() {
    local node_version=$(node -v | sed 's/v//')
    local npm_version=$(npm -v)
    
    if version_gt "$NODE_MIN_VERSION" "$node_version"; then
        handle_error "Node.js version $node_version is below minimum required version $NODE_MIN_VERSION"
    fi
    
    if version_gt "$NPM_MIN_VERSION" "$npm_version"; then
        handle_error "npm version $npm_version is below minimum required version $NPM_MIN_VERSION"
    fi
}

# Backup existing configuration
backup_config() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    if [ -f .nvmrc ]; then
        mv .nvmrc ".nvmrc.backup_${timestamp}"
        log_info "Backed up existing .nvmrc file"
    fi
    if [ -f package.json ]; then
        cp package.json "package.json.backup_${timestamp}"
        log_info "Backed up existing package.json file"
    fi
}

# Check if script is run with correct permissions
if [[ $EUID -eq 0 ]]; then
    handle_error "This script must NOT be run as root"
fi

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 0. Check system dependencies
update_progress "Checking system dependencies"
check_system_dependencies

# 1. Backup existing configuration
update_progress "Backing up existing configuration"
backup_config

# 2. Check current Node.js installation
update_progress "Checking current Node.js installation"
if command -v node >/dev/null 2>&1; then
    current_version=$(node -v)
    log_info "Current Node.js version: $current_version"
else
    log_warning "Node.js not found. Will install via nvm."
fi

# 3. Install/Update nvm
update_progress "Installing/Updating nvm"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

if command -v nvm >/dev/null 2>&1; then
    log_info "nvm is already installed, checking version..."
    current_nvm_version=$(nvm --version)
    log_info "Current nvm version: $current_nvm_version"
else
    log_info "Installing nvm $NVM_VERSION..."
    # Ensure clean state for installation
    rm -rf "$NVM_DIR" 2>/dev/null
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash || handle_error "Failed to install nvm"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# Verify nvm installation
if ! command -v nvm >/dev/null 2>&1; then
    handle_error "nvm installation failed. Please install manually and try again."
fi

# 4. Install LTS Node.js
update_progress "Installing Node.js LTS version"
log_info "Installing Node.js LTS version..."
nvm install --lts || handle_error "Failed to install Node.js LTS"
nvm use --lts || handle_error "Failed to use Node.js LTS"
nvm alias default "lts/*" || log_warning "Failed to set default Node.js version"
node_version=$(node -v)
log_success "Node.js $node_version installed and active"

# Function to handle global npm modules
handle_global_modules() {
    log_info "Checking global npm modules..."
    if command -v corepack >/dev/null 2>&1; then
        log_warning "Found system-level corepack installation"
        log_info "Note: System-level corepack will be ignored by nvm-managed Node.js"
        nvm use --lts
        # Disable corepack features instead of trying to configure it
        export COREPACK_ENABLE=0
    fi
}

# Function to handle npm configurations
configure_npm() {
    log_info "Configuring npm settings..."
    # Disable notifications and warnings
    npm config set fund false
    npm config set audit false
    npm config set update-notifier false
    # Use newer packages to avoid deprecation warnings
    npm config set legacy-peer-deps false
    npm config set package-lock true
    # Disable deprecated package warnings
    export NODE_NO_WARNINGS=1
}

# 5. Configure Node.js environment
update_progress "Configuring Node.js environment"
echo "lts/*" > .nvmrc || handle_error "Failed to create .nvmrc"
configure_npm
handle_global_modules

# 6. Set up core npm packages
update_progress "Installing core development dependencies"
log_info "Installing core development dependencies..."
# Use @latest to ensure we get the newest versions without deprecated dependencies
npm install -g typescript@latest --no-fund --no-audit --no-progress || log_warning "TypeScript installation had warnings"
npm install -g eslint@latest --no-fund --no-audit --no-progress || log_warning "ESLint installation had warnings"
npm install -g jest@latest --no-fund --no-audit --no-progress || log_warning "Jest installation had warnings"

# Install newer versions of potentially problematic packages
npm install -g glob@latest rimraf@latest --no-fund --no-audit --no-progress || log_warning "Utility packages update had warnings"

# 7. Verify installation and environment
update_progress "Verifying installation and environment"
log_info "Verifying Node.js setup..."

# Validate environment
validate_environment || handle_error "Environment validation failed"

# Check core tools and get versions
get_tool_version() {
    local cmd=$1
    local version_flag=${2:---version}
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "$($cmd $version_flag 2>/dev/null)" || echo "Installed (version unavailable)"
    else
        echo "Not installed"
    fi
}

# Check core tools
tools_check=0
command -v node >/dev/null 2>&1 || tools_check=1
command -v npm >/dev/null 2>&1 || tools_check=1
command -v tsc >/dev/null 2>&1 || tools_check=1
command -v eslint >/dev/null 2>&1 || tools_check=1
command -v jest >/dev/null 2>&1 || tools_check=1

if [ $tools_check -eq 0 ]; then
    log_success "Core development environment setup complete!"
    echo -e "\nEnvironment Details:"
    echo "-------------------"
    echo "Node.js: $(node -v)"
    echo "npm: $(npm -v)"
    echo "TypeScript: $(get_tool_version tsc -v)"
    echo "ESLint: $(get_tool_version eslint)"
    echo "Jest: $(get_tool_version jest --version)"
else
    handle_error "Some tools failed to install properly"
fi

# Write setup completion marker with environment details
cat > .core-setup-complete << EOF
Setup completed: $(date '+%Y-%m-%d %H:%M:%S')
Node.js: $(node -v)
npm: $(npm -v)
TypeScript: $(get_tool_version tsc -v)
ESLint: $(get_tool_version eslint)
Jest: $(get_tool_version jest --version)
EOF

log_success "MetaCline core development environment is ready!"
log_info "Next steps:"
echo "1. Run 'source ~/.bashrc' to load nvm in current shell"
echo "2. Verify setup with 'node -v' and 'npm -v'"
echo "3. Proceed with repository structure setup" 