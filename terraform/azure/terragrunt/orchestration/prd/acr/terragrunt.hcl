locals {
  #platform_config = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("MAIN_CONFIG_FILE_NAME"))))
  env_config      = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("ENV_CONFIG_FILE_NAME"))))
  environment = local.env_config.prod_workloads.prd
  # The azurerm provider is dumb when creating security center settings, it applies on the current subscription
  # rather than allow you to specify it.
  # As such, we need this script for every subscription.
  subscription_id = local.env_config.subscriptions.prod_workloads[0].id # This is the line to update to point to the proper sub
}

terraform {
  source = "../../../../modules/acrmodule"

  extra_arguments "force_subscription" {
    commands = [
      "init",
      "apply",
      "destroy",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint"
    ]
    env_vars = {
      ARM_SUBSCRIPTION_ID = local.env_config.subscriptions.prod_workloads[0].id
    }
  }
}


inputs = {
  location = local.env_config.global.locations[0]
  tags     = merge(local.env_config.global.tags, local.environment.tags)
  #tags     =  local.env_config.global.tags
  name = "${local.env_config.global.name_prefix[0]}${local.environment.name[0]}${local.environment.acr.name[0]}"
  resource_group_location = local.env_config.global.locations[0]

  
}

# Generate a special provider.tf to address the generation of dual provider configuration because
# the vnets are in different subscriptions
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

EOF
}

include {
  path = find_in_parent_folders()
}
