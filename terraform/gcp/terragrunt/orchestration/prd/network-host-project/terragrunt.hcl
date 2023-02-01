locals {
  env_config     = yamldecode(file("${get_terragrunt_dir()}/../../config_env_sampleapp.yaml"))
  network         = yamldecode(file("${get_terragrunt_dir()}/../../core-prod-networks.yaml"))
  environment = local.env_config.prod_workloads.prd
}

terraform {
  source = "../../../../modules/network"
  
}

inputs = {
  services                       = local.network.internal.services
  billing_account                = local.network.internal.billing_account
  parent                         = local.env_config.global.project.parent
  networks                        = local.network.internal.networks
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
