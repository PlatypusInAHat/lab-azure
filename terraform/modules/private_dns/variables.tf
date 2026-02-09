# =============================================================================
# Private DNS Module - Variables
# =============================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_id" {
  description = "ID of the Virtual Network to link"
  type        = string
}

variable "dns_zone_app_service" {
  description = "Private DNS Zone name for App Service"
  type        = string
  default     = "privatelink.azurewebsites.net"
}

variable "dns_zone_keyvault" {
  description = "Private DNS Zone name for Key Vault"
  type        = string
  default     = "privatelink.vaultcore.azure.net"
}

variable "dns_zone_storage_blob" {
  description = "Private DNS Zone name for Storage Blob"
  type        = string
  default     = "privatelink.blob.core.windows.net"
}

variable "dns_zone_sql" {
  description = "Private DNS Zone name for SQL Database"
  type        = string
  default     = "privatelink.database.windows.net"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
