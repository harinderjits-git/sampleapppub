data "google_service_account" "default" {
  account_id = "gkek8ssa"
  project    = var.project
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnet_name
  region  = var.region
  project = var.project
}

resource "google_container_cluster" "cluster" {

  name     = var.cluster_name
  project  = var.project
  location = var.region

  network    = data.google_compute_subnetwork.subnetwork.network
  subnetwork = data.google_compute_subnetwork.subnetwork.self_link

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  remove_default_node_pool = "true"
  initial_node_count       = 1

  // Configure various addons
  addons_config {
    // Enable network policy (Calico)
    network_policy_config {
      disabled = false
    }
  }

  // Enable workload identity
  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = "false"
    }
  }

  // Enable network policy configurations (like Calico) - for some reason this
  // has to be in here twice.
  network_policy {
    enabled = "true"
  }

  # // Allocate IPs in our subnetwork
  ip_allocation_policy {
    cluster_secondary_range_name  = data.google_compute_subnetwork.subnetwork.secondary_ip_range.0.range_name
    services_secondary_range_name = data.google_compute_subnetwork.subnetwork.secondary_ip_range.1.range_name
  }

  # // Specify the list of CIDRs which can access the master's API
  # master_authorized_networks_config {
  #   cidr_blocks {
  #     display_name = "bastion"
  #     cidr_block   = format("%s/32", google_compute_instance.bastion.network_interface.0.network_ip)
  #   }
  #}
  // Configure the cluster to have private nodes and private control plane access only
  # private_cluster_config {
  #   enable_private_endpoint = "true"
  #   enable_private_nodes    = "true"
  #   master_ipv4_cidr_block  = var.gke_master_subnet_range
  # }

  // Allow plenty of time for each operation to finish (default was 10m)
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
  node_config {
    labels = var.labels
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = data.google_service_account.default.email
    #  tags            = var.tags
  }

  depends_on = [
    data.google_service_account.default
  ]

  lifecycle {
    ignore_changes = [
      node_config
    ]
  }
}


// A dedicated/separate node pool where workloads will run.  A regional node pool
// will have "node_count" nodes per zone, and will use 3 zones.  This node pool
// will be 3 nodes in size and use a non-default service-account with minimal
// Oauth scope permissions.
resource "google_container_node_pool" "private-np-1" {
  #provider = "google-beta"

  project    = var.project
  name       = "private-np-1"
  location   = var.region
  cluster    = google_container_cluster.cluster.name
  node_count = var.node_count

  // Repair any issues but don't auto upgrade node versions
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    machine_type = var.machine_type
    disk_type    = "pd-ssd"
    disk_size_gb = 30
    #image_type   = "COS"
    #tags         = var.tags
    preemptible = false
    // Use the cluster created service account for this node pool
    service_account = data.google_service_account.default.email

    // Use the minimal oauth scopes needed
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      cluster = var.cluster_name
    }

    // Enable workload identity on this node pool
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      // Set metadata on the VM to supply more entropy
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_container_cluster.cluster,
    data.google_service_account.default
  ]
}
