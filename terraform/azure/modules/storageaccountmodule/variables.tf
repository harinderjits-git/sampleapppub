
variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "httpapp01"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "name" {
  default     = "sampleappacr"
 
}

variable "container_name" {
  type        = string
}


variable "account_replication_type" {
  type        = string
}

variable "tags" {
  type        = map(string)
  
  default = null
}