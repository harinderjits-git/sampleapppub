variable "agent_count" {
  default = 2
}

variable "admin_username" {
  default = "aks_admin"
}


variable "kubernetes_version" {
 
}
variable "vm_size" {
  type        = string
  description = "Resource group object for this consumable. If not set, a new one is created."

  default = null
}
# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "acr_resource_id" {
  default = ""
}

variable "acr_name" {
  default = ""
}

variable "name" {
  default = "aksue"
}


# Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.
variable "log_analytics_workspace_location" {
  default = "eastus"
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

# Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "httpapp01"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "acrname" {
  default     = "sampleappacr"
 
}


variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
variable "tags" {
  type        = map(string)
  
  default = null
}