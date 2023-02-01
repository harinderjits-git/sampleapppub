locals {
  #platform_config = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("MAIN_CONFIG_FILE_NAME"))))
  env_config      = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("ENV_CONFIG_FILE_NAME"))))
  environment = local.env_config.prod_workloads.prddr
  network         = yamldecode(file("${get_terragrunt_dir()}/../../core-prod-networks.yaml"))
}

dependency "gkeprd" {
  config_path = "../../prd/gke"
}

dependency "gkeprddr" {
  config_path = "../gke"
}

dependency vpc {
  config_path = "../../base_infra/vpc"
  skip_outputs = true
}

terraform {
  source = "../../../../modules/lbmodule"

}


inputs = {
  name = "${local.env_config.global.name_prefix[0]}${local.environment.name[0]}${local.environment.loadbalancer.name}"
  dr_gkename = dependency.gkeprddr.outputs.gkename
  primary_gkename = dependency.gkeprd.outputs.gkename
  network = local.network.internal.networks[0].network_name
  primary_region = local.env_config.global.regions[0]
  dr_region = local.env_config.global.regions[1]
  subnet = local.network.internal.networks[0].subnets[1].subnet_name
  dr_igs = dependency.gkeprddr.outputs.igs
  primary_igs = dependency.gkeprd.outputs.igs
  location = local.env_config.global.location
  labels  = merge(local.env_config.global.labels, local.environment.labels)
  project = local.env_config.global.project.id
  # primary_url =local.environment.loadbalancer.primary_url
  # dr_url = local.environment.loadbalancer.dr_url
  appurl = local.environment.loadbalancer.app_url
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
