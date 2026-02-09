# =============================================================================
# Shared Local Values
# =============================================================================
# Naming conventions and common tags used across all modules.
# These locals should be passed to modules as variables.
# =============================================================================

# Usage in environment main.tf:
# locals {
#   project_name    = var.project_name
#   environment     = var.environment
#   location        = var.location
#   resource_suffix = random_string.suffix.result
#   
#   common_tags = {
#     Project     = var.project_name
#     Environment = var.environment
#     ManagedBy   = "Terraform"
#   }
#   
#   # Naming convention
#   name_prefix = "${var.project_name}-${var.environment}"
# }
