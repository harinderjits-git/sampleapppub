module "storageaccount" {
  source                   = "../modules/storageaccountmodule"
  name                     = "remotestaterg20230105"
  account_replication_type = "LRS"
  tags = {
    SolutionProvider = "harinder"
    Solution =  "sampleapp"
  }
  container_name = "tfstatesampleapp"
}
