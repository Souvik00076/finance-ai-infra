#!/bin/bash

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
# Accept SSH host as first argument, default to 'github-personal' if not provided
SSH_HOST="${1:-github-ssh-host}"
FRONTEND_REPO="git@${SSH_HOST}:Souvik00076/finance-ai-frontend.git"
BACKEND_REPO="git@${SSH_HOST}:Souvik00076/finance-ai-backend.git"
API_REPO="git@${SSH_HOST}:Souvik00076/finance-ai-api.git"
BRANCH="master"
FRONTEND_DIR="spendly-frontend"
BACKEND_DIR="spendly-backend"
API_DIR="spendly-api"
FRONTEND_IMAGE="spendly-frontend"
BACKEND_IMAGE="spendly-backend"
API_IMAGE="spendly-api"

# Functions
print_step() {
  echo -e "${BLUE}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Check if SSH key is configured
check_ssh() {
  echo -e "${GREEN}"
  print_step "Checking SSH configuration..."
  if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_warning "SSH connection to GitHub may not be properly configured"
    print_warning "Continuing anyway... (error will occur if SSH is not set up)"
  else
    print_success "SSH authentication verified"
  fi
  echo -e "${NC}"
}

# Clone or update repository
clone_or_update() {
  local repo_url=$1
  local repo_dir=$2
  local branch=$3

  if [ -d "$repo_dir" ]; then
    print_warning "$repo_dir already exists"
    read -p "Do you want to pull latest changes from '$branch' branch? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_step "Pulling latest changes for $repo_dir from '$branch' branch..."
      (
        cd "$repo_dir"
        git checkout "$branch"
        git pull origin "$branch"
        cd ..
      ) &
      print_success "Repository updated to latest '$branch'"
    else
      print_warning "Skipping repository update"
    fi
  else
    (
      print_step "Cloning $repo_dir (branch: $branch)..."
      git clone -b "$branch" "$repo_url" "$repo_dir"
      print_success "Repository cloned from '$branch' branch"
    ) &
  fi
}

# Build Docker image
build_image() {
  local dir=$1
  local image=$2
  local build_args=$3

  print_step "Building Docker image: $image from $dir/Dockerfile"

  if [ -n "$build_args" ]; then
    docker build $build_args -f "./$dir/Dockerfile" -t "$image" "./$dir"
  else
    docker build -f "./$dir/Dockerfile" -t "$image" "./$dir"
  fi

  print_success "Image built: $image"
}

# Main execution
main() {
  echo -e "${GREEN}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║  Spendly Environment Setup                ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check SSH
  check_ssh

  echo ""
  print_step "Step 1: Cloning repositories from '$BRANCH' branch..."
  echo ""

  # Clone frontend
  clone_or_update "$FRONTEND_REPO" "$FRONTEND_DIR" "$BRANCH"
  # Clone backend
  clone_or_update "$BACKEND_REPO" "$BACKEND_DIR" "$BRANCH"
  # Clone Api
  clone_or_update "$API_REPO" "$API_DIR" "$BRANCH"

  wait

  echo ""
  print_step "Step 2: Building Docker images..."
  echo ""

  # Build frontend image (with APP_ENV=development arg)
  build_image "$FRONTEND_DIR" "$FRONTEND_IMAGE" "--build-arg APP_ENV=production"

  # Build backend image
  build_image "$BACKEND_DIR" "$BACKEND_IMAGE" ""

  # Build API image
  build_image "$API_DIR" "$API_IMAGE" ""

  echo ""
  echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║           Setup Complete! ✓               ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
  echo ""

  print_success "Images built successfully:"
  docker images | grep -E "REPOSITORY|finance-ai-(frontend|backend|api)" | head -3

  echo -e "$RED"
  echo ""
  print_step "Next steps:"
  echo "  1. Ensure .env.frontend, .env.backend and .env.api are configured"
  echo "  2. Run: docker-compose up -d"
  echo "  3. Check logs: docker-compose logs -f"
  echo ""
  echo -e "$NC"
}

# Run main function
main
