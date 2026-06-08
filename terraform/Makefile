TF_DEV_OPTS  = -var-file=environments/dev/main.tfvars
TF_PROD_OPTS = -var-file=environments/prod/main.tfvars
DEV_CLUSTER  = dev
DEV_REGION   = us-east-1
PROD_CLUSTER = prod
PROD_REGION  = us-east-1

define tf_init_dev
	git pull
	rm -f .terraform/terraform.tfstate
	terraform init -backend-config=environments/dev/state.tfvars
endef

define tf_init_prod
	git pull
	rm -f .terraform/terraform.tfstate
	terraform init -backend-config=environments/prod/state.tfvars
endef

# 0) Helm uninstall while API is up + state rm helm releases
# 1) EKS addons/nodes/cluster
# 2) EC2 DB tier
# 3) VPC and everything else
define tf_destroy_staged
	@echo "Stage 0/4: Helm uninstall + remove helm_release from state..."
	-./scripts/eks-destroy-prep.sh $(2) $(3)
	@echo "Stage 1/4: destroying EKS (addons, nodes, cluster)..."
	-terraform destroy -auto-approve -target=module.eks $(1)
	@echo "Stage 2/4: destroying EC2 DB tier..."
	-terraform destroy -auto-approve -target=module.ec2 $(1)
	@echo "Stage 3/4: destroying VPC and remaining resources..."
	terraform destroy -auto-approve $(1)
endef

dev-apply:
	$(call tf_init_dev)
	terraform apply -auto-approve $(TF_DEV_OPTS)

dev-destroy:
	$(call tf_init_dev)
	$(call tf_destroy_staged,$(TF_DEV_OPTS),$(DEV_CLUSTER),$(DEV_REGION))

prod-apply:
	$(call tf_init_prod)
	terraform apply -auto-approve $(TF_PROD_OPTS)

prod-destroy:
	$(call tf_init_prod)
	$(call tf_destroy_staged,$(TF_PROD_OPTS),$(PROD_CLUSTER),$(PROD_REGION))
