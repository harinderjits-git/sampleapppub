locals {
  #platform_config = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("MAIN_CONFIG_FILE_NAME"))))
  env_config      = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("ENV_CONFIG_FILE_NAME"))))
  environment = local.env_config.prod_workloads.prddr
  network         = yamldecode(file("${get_terragrunt_dir()}/../../core-prod-networks.yaml"))
}

dependency "gcr" {
  config_path = "../../prd/gcr"
}

dependency vpc {
  config_path = "../../base_infra/vpc"
  skip_outputs = true
}

terraform {
  source = "../../../../modules/gkemodule"

}


inputs = {

  cluster_name = "${local.env_config.global.name_prefix[0]}${local.environment.name[0]}${local.environment.gke.name[0]}"
  machine_type = local.environment.gke.gke_agent_vm_size
 # network_name = local.network.internal.networks[0].network_name
  subnet_name = local.network.internal.networks[0].subnets[1].subnet_name
  #kubernetes_version = local.environment.gke.kubernetes_version
  location = local.env_config.global.location
  labels     = merge(local.env_config.global.labels, local.environment.labels)
  project = local.env_config.global.project.id
  node_count = local.environment.gke.node_count_per_ig
  region = local.environment.region
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.48.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.48.0"
    }
  }
  required_version = "1.2.3"
}
EOF
}


include {
  path = find_in_parent_folders()
}
