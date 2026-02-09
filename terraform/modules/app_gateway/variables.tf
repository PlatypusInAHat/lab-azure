# =============================================================================
# Application Gateway Module - Variables
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

variable "subnet_id" {
  description = "ID of the Application Gateway subnet"
  type        = string
}

variable "backend_fqdn" {
  description = "FQDN of the backend (App Service)"
  type        = string
}

variable "sku" {
  description = "SKU tier for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Capacity (instance count)"
  type        = number
  default     = 2
}

variable "public_ip_sku" {
  description = "SKU for Public IP"
  type        = string
  default     = "Standard"
}

variable "public_ip_allocation_method" {
  description = "Allocation method for Public IP"
  type        = string
  default     = "Static"
}

variable "http_port" {
  description = "HTTP frontend port"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Backend port (HTTPS)"
  type        = number
  default     = 443
}

variable "request_timeout" {
  description = "Request timeout in seconds"
  type        = number
  default     = 60
}

variable "ssl_policy" {
  description = "SSL policy name"
  type        = string
  default     = "AppGwSslPolicy20220101"
}

variable "health_probe_interval" {
  description = "Health probe interval in seconds"
  type        = number
  default     = 30
}

variable "health_probe_timeout" {
  description = "Health probe timeout in seconds"
  type        = number
  default     = 30
}

variable "health_probe_unhealthy_threshold" {
  description = "Unhealthy threshold"
  type        = number
  default     = 3
}

variable "routing_rule_priority" {
  description = "Priority for routing rule"
  type        = number
  default     = 100
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
