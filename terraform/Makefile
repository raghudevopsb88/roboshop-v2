TF_DEV_OPTS  = -var-file=environments/dev/main.tfvars
TF_PROD_OPTS = -var-file=environments/prod/main.tfvars

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

# Destroy EKS first, then EC2, then VPC — avoids subnet/ENI dependency errors.
define tf_destroy_staged
	@echo "Stage 1/3: destroying EKS (helm, addons, nodes, cluster)..."
	-terraform destroy -auto-approve -target=module.eks $(1)
	@echo "Stage 2/3: destroying EC2 DB tier..."
	-terraform destroy -auto-approve -target=module.ec2 $(1)
	@echo "Stage 3/3: destroying VPC and remaining resources..."
	terraform destroy -auto-approve $(1)
endef

dev-apply:
	$(call tf_init_dev)
	terraform apply -auto-approve $(TF_DEV_OPTS)

dev-destroy:
	$(call tf_init_dev)
	$(call tf_destroy_staged,$(TF_DEV_OPTS))

prod-apply:
	$(call tf_init_prod)
	terraform apply -auto-approve $(TF_PROD_OPTS)

prod-destroy:
	$(call tf_init_prod)
	$(call tf_destroy_staged,$(TF_PROD_OPTS))
