
locals {
  env_config      = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("ENV_CONFIG_FILE_NAME"))))
  tfstate_key = replace(get_terragrunt_dir(), get_env("ORCHESTRATION_PATH"), "orchestration")
}

# Remote State Configuration
remote_state {
  backend = "gcs"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = local.env_config.global.remote_state.bucket_name
    prefix = "${path_relative_to_include()}"
    project = local.env_config.global.project.id
    location = local.env_config.global.location
  }
}