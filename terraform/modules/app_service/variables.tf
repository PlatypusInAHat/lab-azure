# =============================================================================
# App Service Module - Variables
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

variable "vnet_integration_subnet_id" {
  description = "ID of the VNet Integration subnet"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "ID of the Private Endpoint subnet"
  type        = string
}

variable "dns_zone_id" {
  description = "ID of the App Service Private DNS Zone"
  type        = string
}

variable "sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "S1"
}

variable "always_on" {
  description = "Enable Always On"
  type        = bool
  default     = true
}

variable "dotnet_version" {
  description = ".NET version"
  type        = string
  default     = "8.0"
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "App settings map"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
