

variable "name" {
  default = "tfprofile"
}

variable "resource_group_location" {
  default     = "eastus2"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "tfprofile-rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "routing_method" {
  default = ""
}

variable "dr_aksname" {
  default = ""
}

variable "primary_aksname" {
  default = ""
}
# variable "endpoints" {
#   type=map(map(string))
# }
variable "ep_pr" {
   type=map(string)
}

variable "ep_dr" {
   type=map(string)
}
variable "tags" {
  type        = map(string)
  
  default = null
}