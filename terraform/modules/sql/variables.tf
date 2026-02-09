# =============================================================================
# SQL Module - Variables
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
  description = "ID of the SQL Private DNS Zone"
  type        = string
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "server_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "database_sku" {
  description = "SKU for SQL Database"
  type        = string
  default     = "Basic"
}

variable "max_size_gb" {
  description = "Maximum size in GB"
  type        = number
  default     = 2
}

variable "zone_redundant" {
  description = "Enable zone redundancy"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
