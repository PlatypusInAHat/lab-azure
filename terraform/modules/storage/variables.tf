# =============================================================================
# Storage Module - Variables
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

variable "private_endpoint_subnet_id" {
  description = "ID of the Private Endpoint subnet"
  type        = string
}

variable "dns_zone_id" {
  description = "ID of the Storage Blob Private DNS Zone"
  type        = string
}

variable "app_service_principal_id" {
  description = "Principal ID of App Service managed identity"
  type        = string
}

variable "container_name" {
  description = "Name of blob container"
  type        = string
  default     = "user-pictures"
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
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
