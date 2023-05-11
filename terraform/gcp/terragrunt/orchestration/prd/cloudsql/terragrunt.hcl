locals {
  #platform_config = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("MAIN_CONFIG_FILE_NAME"))))
  env_config      = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("ENV_CONFIG_FILE_NAME"))))
  environment = local.env_config.prod_workloads.prd
    network         = yamldecode(file("${get_terragrunt_dir()}/../../core-prod-networks.yaml"))
}

dependency vpc {
  config_path = "../../base_infra/vpc"
  skip_outputs = true
}
dependency master {

  config_path = "../../prddr/cloudsql"

}
terraform {
  source = "../../../../modules/cldsqlmodule"

}


inputs = {
  location = local.env_config.global.location
  labels     = merge(local.env_config.global.labels, local.environment.labels)
  project = local.env_config.global.project.id
  network_name = local.network.internal.networks[0].network_name
  dnsname =  local.network.internal.dns.name
  #tags     =  local.env_config.global.tags
  name = "${local.env_config.global.name_prefix[0]}${local.environment.name[0]}${local.environment.cldsqlserver.name}"
  databases = local.environment.cldsqlserver.dbs
  region = local.environment.region
  administrator_login = local.environment.cldsqlserver.admin_login
  administrator_login_password = local.environment.cldsqlserver.admin_password
  dblogins = local.environment.cldsqlserver.dblogins
 master_instance_name = dependency.master.outputs.sql_instance
}

# Generate a special provider.tf to address the generation of dual provider configuration because
# the vnets are in different subscriptions
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
