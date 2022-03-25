.PHONY: tf-init tf-plan tf-apply tf-destroy

TF = terraform
TFVAR = -var-file=./terraform.tfvars

tf-init:
	${TF} init

tf-plan:
	${TF} plan ${TFVAR}

tf-apply:
	${TF} apply ${TFVAR} -auto-approve

tf-destroy:
	${TF} destroy ${TFVAR} -auto-approve