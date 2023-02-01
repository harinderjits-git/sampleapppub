variable "database_name" {
  default     = "sampleappdb"
  
}

variable "databases" {
type = map (map(string))
 
}
variable "dblogins" {
type = map (map(string))
 
}
variable "database_server_name" {
  default     = "sampleappserver-primary"
  
}

variable "resource_group" {
  type        = any
  description = "Resource group object for this consumable. If not set, a new one is created."

  default = null
}
variable "administrator_login" {
  default     = "sqladmin"
  
}
variable "administrator_login_password" {
  default     = ""
  
}
variable "db_sku" {
  default     = "appuser"
  
}
variable "logicapp_name" {
  
}
# variable "local_ip_addresses" {
#   type = list(string)

# }


variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "httpapp01"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}


variable "tags" {
  type        = map(string)
  
  default = null
}