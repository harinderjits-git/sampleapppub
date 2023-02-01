locals {
  env_config     = yamldecode(file("${get_terragrunt_dir()}/../../config_env_sampleapp.yaml"))
  network         = yamldecode(file("${get_terragrunt_dir()}/../../core-prod-networks.yaml"))
  environment = local.env_config.prod_workloads.prd
}

dependency vpc {
  config_path = "../vpc"
  skip_outputs = true
}
terraform {
  source = "../../../../modules/privatedns"
  
}

inputs = {
  labels     = merge(local.env_config.global.labels, local.environment.labels)
  dns = local.network.internal.dns
  target_network = local.network.internal.networks[0].network_name
  environment                    = local.environment.name[0]
  region                         = local.env_config.global.regions[0]
  owner                          = local.env_config.global.owner
  user_defined_string            = local.network.internal.userDefinedString
  additional_user_defined_string = local.network.internal.additionalUserDefinedString
  department_code                = "DEV"
  project                        = local.env_config.global.project.id
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
    experiments = [module_variable_optional_attrs]
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
