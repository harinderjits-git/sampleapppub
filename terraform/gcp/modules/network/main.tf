
module "network" {
  source          = "./vpc"
  for_each        = { for network in var.networks : network.network_name => network }
  project         = var.project
  department_code = var.department_code
  owner           = var.owner
  environment     = var.environment
  network         = each.value
}
