#!/bin/bash
# =============================================================================
# Deploy Script for Modular Terraform (WSL/Bash)
# =============================================================================
# Usage:
#   ./deploy.sh                    # Deploy dev (interactive)
#   ./deploy.sh -e prod            # Deploy prod
#   ./deploy.sh -a                 # Auto-approve
#   ./deploy.sh -p                 # Phase 2 (lock down)
#   ./deploy.sh -d                 # Destroy infrastructure
# =============================================================================

set -e

# Defaults
ENV="dev"
AUTO_APPROVE=""
PHASE2=false
DESTROY=false
PLAN_ONLY=false

# Parse arguments
while getopts "e:apdh" opt; do
  case $opt in
    e) ENV="$OPTARG" ;;
    a) AUTO_APPROVE="-auto-approve" ;;
    p) PHASE2=true ;;
    d) DESTROY=true ;;
    h)
      echo "Usage: $0 [-e env] [-a] [-p] [-d]"
      echo "  -e env    Environment (dev/prod), default: dev"
      echo "  -a        Auto-approve"
      echo "  -p        Phase 2 (lock down public access)"
      echo "  -d        Destroy infrastructure"
      exit 0
      ;;
    *) echo "Invalid option"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_PATH="$SCRIPT_DIR/envs/$ENV"

# Check terraform.tfvars
if [ ! -f "$ENV_PATH/terraform.tfvars" ]; then
  echo -e "\033[31mERROR: terraform.tfvars not found!\033[0m"
  echo -e "\033[33mCopy and edit terraform.tfvars.example:\033[0m"
  echo -e "\033[36m  cp $ENV_PATH/terraform.tfvars.example $ENV_PATH/terraform.tfvars\033[0m"
  exit 1
fi

cd "$ENV_PATH"
echo -e "\033[36m=== Environment: $ENV ===\033[0m"
echo "Working directory: $ENV_PATH"

# Initialize
echo -e "\n\033[33m[1/3] Initializing Terraform...\033[0m"
terraform init -upgrade

# Set public_network_access - now defaults to false (Trusted Services bypass enabled)
if [ "$PHASE2" = true ]; then
  PUBLIC_ACCESS="false"
  PHASE_LABEL="Private Mode (Trusted Services Bypass)"
else
  PUBLIC_ACCESS="false"  # Default to private now
  PHASE_LABEL="Private Mode (Trusted Services Bypass)"
fi

echo -e "\n\033[35m[2/3] $PHASE_LABEL - public_network_access_enabled=$PUBLIC_ACCESS\033[0m"

# Execute
if [ "$DESTROY" = true ]; then
  echo -e "\n\033[31m[3/3] DESTROYING infrastructure...\033[0m"
  terraform destroy -var="public_network_access_enabled=$PUBLIC_ACCESS" $AUTO_APPROVE
else
  echo -e "\n\033[32m[3/3] Applying changes...\033[0m"
  terraform apply -var="public_network_access_enabled=$PUBLIC_ACCESS" $AUTO_APPROVE
  
  echo -e "\n\033[32m=== Deployment Complete ===\033[0m"
  terraform output
fi
