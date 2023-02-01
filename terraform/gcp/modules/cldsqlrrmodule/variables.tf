// Required values to be set in terraform.tfvars
variable "project" {
  description = "The project in which to hold the components"
  type        = string
}

variable "region" {
  description = "The region in which to create the VPC network"
  type        = string
  default     = "northamerica-northeast1"
}

variable "zone" {
  description = "The zone in which to create the Kubernetes cluster. Must match the region"
  type        = string
  default     = "northamerica-northeast1-a"
}


// Optional values that can be overridden or appended to if desired.
variable "master_instance_name" {
  description = "The name to give the new sql cluster."
  type        = string
  default     = "private-cluster-1"
}

variable "labels" {
  type        = map(string)

}
variable "admin_login" {
  type        = string
  default     = "sqladmin"
}
variable "admin_password" {
  type        = string
  default     = "dasfscdsvcs"
}
variable "network_name" {
  type        = string
  default     = "internalnet"
}
variable "database_version" {
default = "SQLSERVER_2019_ENTERPRISE"
}



variable "readreplica" {
  default = {}
  type = map(map(string))
}
