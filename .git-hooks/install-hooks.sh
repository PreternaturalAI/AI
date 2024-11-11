#!/bin/sh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔧 Installing git hooks..."

# Check if gitleaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo -e "${RED}❌ Error: gitleaks is not installed${NC}"
    echo "Please install gitleaks first:"
    echo "  brew install gitleaks    # macOS"
    echo "  or visit: https://github.com/zricethezav/gitleaks/releases"
    exit 1
fi

# Get the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel)

# Create hooks directory if it doesn't exist
mkdir -p "$REPO_ROOT/.git/hooks"

# Create symbolic link to pre-commit hook
ln -sf "$REPO_ROOT/.git-hooks/pre-commit" "$REPO_ROOT/.git/hooks/pre-commit"

# Make the hook executable
chmod +x "$REPO_ROOT/.git-hooks/pre-commit"

echo -e "${GREEN}✅ Git hooks installed successfully${NC}"
