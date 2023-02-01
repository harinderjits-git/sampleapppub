# -------------------------------------
# APPLY - 
# -------------------------------------
apply-base-infra:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/base_infra

apply-prd-gcr:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prd/gcr

apply-prd-gke:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prd/gke

apply-prd-cloudsql:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prd/cloudsql

apply-prd-all-no-ha: apply-base-infra apply-prd-gcr apply-prd-gke apply-prd-cloudsql

	

apply-prddr-gke:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prddr/gke


apply-prddr-cloudsql:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prddr/cloudsql


apply-all-ha:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/


destroy-all-ha:
	terragrunt run-all destroy --terragrunt-non-interactive --terragrunt-working-dir orchestration/
