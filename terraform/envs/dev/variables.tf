# =============================================================================
# Dev Environment - Variables
# =============================================================================

# General
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "labazure"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East Asia"
}

# Network
variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_gw_prefix" {
  description = "App Gateway subnet prefix"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_vnet_integration_prefix" {
  description = "VNet Integration subnet prefix"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_private_endpoint_prefix" {
  description = "Private Endpoint subnet prefix"
  type        = string
  default     = "10.0.3.0/24"
}

# SQL
variable "sql_admin_username" {
  description = "SQL admin username"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}

variable "sql_database_sku" {
  description = "SQL database SKU"
  type        = string
  default     = "Basic"
}

# App Service
variable "app_service_sku" {
  description = "App Service SKU"
  type        = string
  default     = "S1"
}

# App Gateway
variable "app_gateway_sku" {
  description = "App Gateway SKU"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_capacity" {
  description = "App Gateway capacity"
  type        = number
  default     = 2
}

# Storage
variable "blob_container_name" {
  description = "Blob container name"
  type        = string
  default     = "user-pictures"
}

# Security
variable "public_network_access_enabled" {
  description = "Enable public network access (for 2-phase deployment)"
  type        = bool
  default     = true
}
