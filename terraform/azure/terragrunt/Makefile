# -------------------------------------
# APPLY - 
# -------------------------------------
apply-prd-acr:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prd/acr

apply-prd-aks:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prd/aks

apply-prd-mssql:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prd/mssql

apply-prd-all-no-ha: apply-prd-aks apply-prd-mssql

	

apply-prddr-aks:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prddr/aks


apply-prddr-mssql:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/prddr/mssql


apply-all-ha:
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir orchestration/


destroy-all-ha:
	terragrunt run-all destroy --terragrunt-non-interactive --terragrunt-working-dir orchestration/

# ---
# ------------------------------------------------------------------------------
# TESTS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# TG DEV
# ------------------------------------------------------------------------------
# tg-live-infra:
# ifdef TG_WD
# 	source $(SET_ENV_SH)
# 	@echo "$(TG_CMD) $(TG_WD)"
# 	terragrunt run-all $(TG_CMD) --terragrunt-working-dir $(TG_WD) $(TG_ADD_PARAMS)
# endif

# tg-live-infra-full-cmds:
# ifdef TG_WD
# 	source $(SET_ENV_SH)
# 	@echo "$(TG_CMD) $(TG_WD)"
# 	terragrunt $(TG_CMD) --terragrunt-working-dir $(TG_WD) $(TG_ADD_PARAMS)
# endif
