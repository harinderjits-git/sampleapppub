# network
output "network" {
  value       = google_compute_network.vpc
  description = "The VPC resource being created"
}

output "network_name" {
  value       = google_compute_network.vpc.name
  description = "The name of the VPC being created"
}

output "short_name" {
  value       = var.network.network_name
  description = "use for reference in outputs"
}

output "network_self_link" {
  value       = google_compute_network.vpc.self_link
  description = "The URI of the VPC being created"
}

## subnets
output "subnets" {
  value       = { for key, subnet in google_compute_subnetwork.subnetwork : subnet.name => subnet }
  description = "The created subnet resources"
}

## routes 
output "routes" {
  value       = google_compute_route.route
  description = "The created routes resources"
}

## routers
output "routers" {
  value       = { for router in google_compute_router.router : router.name => router }
  description = "The created routes resources"
}

## nats

# output "nats" {
#   value       = { for nat in module.cloud_nat : nat.cloud_nat.name => nat }
#   description = "The created NAT resources"
# }