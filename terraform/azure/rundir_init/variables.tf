variable "database_name" {
  default     = "sampleappdb"
  
}

variable "database_server_name" {
  default     = "sampleappserver-primary"
  
}

variable "administrator_login" {
  default     = "sqladmin"
  
}
variable "administrator_login_password" {
  default     = ""
  
}
variable "application_login" {
  default     = "appuser"
  
}



variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "httpapp01"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}


variable "agent_count" {
  default = 2
}


variable "cluster_name" {
  default = "aksue"
}

variable "dns_prefix" {
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


variable "acrname" {
  default     = "sampleappacr"
 
}


variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}