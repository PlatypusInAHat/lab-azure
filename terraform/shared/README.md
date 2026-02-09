# Shared Terraform Configuration

This directory contains shared configuration files used across all environments.

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider version constraints |
| `locals.tf` | Template for naming conventions and common tags |

## Usage

These files serve as templates. Copy or reference them in your environment configuration.

```hcl
# In envs/dev/main.tf or envs/prod/main.tf
# Copy the terraform block from versions.tf
# Adapt locals.tf template for your environment
```
