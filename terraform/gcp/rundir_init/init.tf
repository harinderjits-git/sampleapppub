module "project" {
  source = "../modules/projectmodule"
  labels = {
    "solutionprovider" = "harinder"
    "solution"         = "sampleapp"
  }
  parent          = "folders/446826717580" #replace this
  project_name    = "mysampleappproj1-86868"
  project_id      = "mysampleappproj1-f68685"
  billing_account = "00E11A-0AB9A2-077BE7" #replace this
  services        = [
  "sqladmin.googleapis.com",
  "containerregistry.googleapis.com"
  ,"container.googleapis.com"
  ,"sql-component.googleapis.com"
  ,"dns.googleapis.com"
  ,"servicenetworking.googleapis.com"
  ,"compute.googleapis.com"
  ,"iam.googleapis.com"
  ,"logging.googleapis.com"
  ,"monitoring.googleapis.com"
  ,"sqladmin.googleapis.com"
  ,"securetoken.googleapis.com"
  ,"cloudfunctions.googleapis.com"
  ,"cloudbuild.googleapis.com"
  ,"cloudapis.googleapis.com"
  ,"cloudkms.googleapis.com"]
}


module "bucket" {
  source = "../modules/bucketmodule"
  labels = {
    solutionprovider = "harinder"
    solution         = "sampleapp"
  }
  project_id = "mysampleappproj1-f68685"
  location   = "US"
  bucketname = "tfstateremote10xxx"
  depends_on = [
    module.project
  ]
}
