# =============================================================================
# Key Vault Module - Variables
# =============================================================================

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "resource_suffix" {
  description = "Suffix for unique resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "ID of the Private Endpoint subnet"
  type        = string
}

variable "dns_zone_id" {
  description = "ID of the Key Vault Private DNS Zone"
  type        = string
}

variable "app_service_principal_id" {
  description = "Principal ID of App Service managed identity"
  type        = string
}

variable "deployer_object_id" {
  description = "Object ID of the deployer (for Key Vault admin access)"
  type        = string
}

variable "sql_connection_string" {
  description = "SQL connection string to store as secret"
  type        = string
  sensitive   = true
}

variable "sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
