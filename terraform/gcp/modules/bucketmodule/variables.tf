

variable "labels" {
  description = "Resource labels."
  type        = map(string)
  default     = {}
}

# naming
variable "project_id" {
  type        = string
}

variable "bucketname" {
  type        = string

}


variable "location" {
  type        = string
 
}

