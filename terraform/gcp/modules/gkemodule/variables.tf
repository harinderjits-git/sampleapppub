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
variable "cluster_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = string
  default     = "private-cluster-1"
}
variable "subnet_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = string

}
variable "node_pool" {
  description = "The name to give the Kubernetes node pool."
  type        = string
  default     = "private-np-1"
}
variable "node_count" {
  type        = string
  default     = "1"
}
variable "machine_type" {
  description = "machine_type"
  type        = string

}

variable "labels" {
  type        = map(string)

}


