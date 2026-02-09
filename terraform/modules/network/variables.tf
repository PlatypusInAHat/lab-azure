# =============================================================================
# Network Module - Variables
# =============================================================================

variable "name_prefix" {
  description = "Prefix for resource names"
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

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_gw_prefix" {
  description = "Address prefix for Application Gateway subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_vnet_integration_prefix" {
  description = "Address prefix for VNet Integration subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_private_endpoint_prefix" {
  description = "Address prefix for Private Endpoint subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
