output "id" {
  value = local.consumable.id
}

output "k8sversion" {
  value = google_container_cluster.cluster.master_version
}

output "gkename" {
  value = google_container_cluster.cluster.name
}

output "igs" {
  value = google_container_node_pool.private-np-1.instance_group_urls
}
