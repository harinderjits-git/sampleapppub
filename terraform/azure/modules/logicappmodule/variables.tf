variable "name" {
    type = string
    default = "logicwflogin"
}

#var.sqlserver_instance_name,var.database_name,var.username,var.password
variable "database_server_name" {
    type = string
default = "sqlserever1"
}

variable "database_name" {
    type = string
default = "sampleappdb"
}

variable "administrator_login" {
    type = string
default = "sqladmin"
}

variable "parameters" {
  description = "The parameters passed to the workflow"
  default     = {}
}


variable "administrator_login_password" {
    type = string
}



variable "appuser" {
    type = string
    default = "appuser"

}
variable "applogin" {
    type = string
default = "Sqlnnjkd5454"
}



variable "tags" {
  type        = map(string)
  
  default = null
}



variable "resource_group_location" {
    type = string
default = "eastus"
}