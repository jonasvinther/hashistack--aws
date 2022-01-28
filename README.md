# Hashistack AWS

## Table of Contents

- [About](#about)
- [How to use](#how-to-use)
  * [Getting started](#getting-started)
  * [Create and update the cluster](#create-and-update-the-cluster)
  * [Destroy the cluster](#destroy-the-cluster)

## About
This project is inspiret by the two HashiCorp projects [terraform-aws-nomad](https://github.com/hashicorp/terraform-aws-nomad) and [terraform-aws-consul](https://github.com/hashicorp/terraform-aws-consul). I wanted to learn more about how to setup and configure Nomad and Consul on AWS using Terraform in a production grade environment.

## How to use

### Getting started
Make a copy of `terraform.tfvars.example` and rename it to `terraform.tfvars`.

Fill out the two AWS variables `aws_access_key_id` and `aws_secret_access_key` with your personal AWS keys.

### Create and update the cluster
The first time you run the project you need to initialize the Terraform working directory.
```
terraform init
```

For creating and updating the cluster use the following commands:
```
# Generates the Terraform execution plan. Verify that everything looks ok
terraform plan

# Apply the Terraform configuration to AWS
terraform apply --auto-aprove
```

### Destroy the cluster
To destroy the cluster simply run the following command. This will clean up all the Terraform managed infrastructure on AWS.

```
terraform destroy --auto-aprove
```

