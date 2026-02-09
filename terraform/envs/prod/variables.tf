# =============================================================================
# Prod Environment - Variables
# =============================================================================

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.1.0.0/16"] # Different from dev
}

variable "subnet_app_gw_prefix" {
  type    = string
  default = "10.1.1.0/24"
}

variable "subnet_vnet_integration_prefix" {
  type    = string
  default = "10.1.2.0/24"
}

variable "subnet_private_endpoint_prefix" {
  type    = string
  default = "10.1.3.0/24"
}

variable "sql_admin_username" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "sql_database_sku" {
  type    = string
  default = "S1" # Higher SKU for production
}

variable "app_service_sku" {
  type    = string
  default = "P1v2" # Premium for production
}

variable "app_gateway_sku" {
  type    = string
  default = "Standard_v2"
}

variable "app_gateway_capacity" {
  type    = number
  default = 3 # More capacity for production
}

variable "blob_container_name" {
  type    = string
  default = "user-pictures"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false # Default to private for production
}
