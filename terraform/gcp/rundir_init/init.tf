module "project" {
  source = "../modules/projectmodule"
  labels = {
    "solutionprovider" = "harinder"
    "solution"         = "sampleapp"
  }
  parent          = "folders/54XXXX" #replace this
  project_name    = "mysampleappproj1-ffgd"
  project_id      = "mysampleappproj1-ffgd12345"
  billing_account = "00E11A-XXXX" #replace this
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
  ,"cloudapis.googleapis.com"]
}


module "bucket" {
  source = "../modules/bucketmodule"
  labels = {
    solutionprovider = "harinder"
    solution         = "sampleapp"
  }
  project_id = "mysampleappproj1-ffgd12345"
  location   = "US"
  bucketname = "tfstateremote10xxx"
  depends_on = [
    module.project
  ]
}
