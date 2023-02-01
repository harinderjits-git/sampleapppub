
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

variable "resource_group" {
  type        = any
  description = "Resource group object for this consumable. If not set, a new one is created."

  default = null
}

variable "tags" {
  type        = map(string)
  
  default = null
}