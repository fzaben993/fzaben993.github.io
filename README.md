# Infrastructure as Code using Terraform and CloudFormation

This repository contains the code for the infrastructure as code (IaC) for the project using terrafrom or AWS cloudformation.

The Code will create the resources as split into two parts:

Network:
    - VPC
    - Internet Gateway
    - Subnets (Public and Private)
    - Route Tables and Routes
    - Elastic IPs
    - NAT Gateways

Server
    - Security Groups
    - EC2 Instances
    - Load Balancer
    - Auto Scaling Group
    - Launch Configuration

## Pre-requisites

- AWS account
- AWS CLI
- Terraform
- Visual Studio Code

## CloudFormation

The CloudFormation directory contains the CloudFormation scripts to create the network infrastructure then the server infrastructure.

- network.yml: This file contains the network resources like VPC, Subnets, Route Tables, etc.
- network-parameters.json: This file contains the parameters for the network resources like VPC CIDR, Subnet CIDR, etc.
- servers.yml: This file contains the server resources like Security Groups, EC2 Instances, etc.
- servers-parameters.json: This file contains the parameters for the server.

Change the directory to the cloudformation directory:

```sh
cd iac/cloudformation
```

Examples to create, update, describe, and delete the stack using the AWS CLI, PowerShell, and Bash for network resources.
The same can be used for server resources by changing the stack name, template file names and parameters file names.

Create stack:

- aws cli

```sh
aws cloudformation create-stack --stack-name my-stack --region eu-west-1 --template-body file://network.yml --parameters file://network-parameters.json

```

PowerShell:

```powershell
.\create.ps1 "my-stack"  "network.yml" "network-parameters.json"
```

Bash

```sh
./create.sh "my-stack"  "network.yml" "network-parameters.json"
```

Update stack:

- aws cli

```sh
aws cloudformation update-stack --stack-name my-stack --region eu-west-1 --template-body file://network.yml --parameters file://network-parameters.json
```

```powershell
.\update.ps1 "my-stack"  "network.yml" "network-parameters.json"
```

Bash

```sh
./update.sh "my-stack"  "network.yml" "network-parameters.json"
```

Describe stack:

```sh
aws cloudformation describe-stacks --stack-name my-stack --region eu-west-1
```

Delete stack:

```sh
aws cloudformation delete-stack --stack-name my-stack --region eu-west-1
```

## Terraform

Set AWS credentials:

Bash

```sh
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
```

PowerShell

```powershell
$env:AWS_ACCESS_KEY_ID = "anaccesskey"
$env:AWS_SECRET_ACCESS_KEY = "asecretkey"
```

> Note: The above method is not recommended for production use. see [3 ways to configure terraform to use your AWS account](https://banhawy.medium.com/3-ways-to-configure-terraform-to-use-your-aws-account-fb00a08ded5)

Change the directory to the terraform directory:

```sh
cd iac/terraform
```

Initialize the dependency:

```sh
terraform init
```

Show the plan:

```sh
terraform plan
```

Apply the plan:

```sh
terraform apply -auto-approve
```

Destroy the infrastructure:

```sh
terraform apply -auto-approve -destroy
```

## Glossary in CloudFormation scripts

- Name: A name you want to give to the resource (does this have to be unique across all resource types?)

- Type: Specifies the actual hardware resource that you’re deploying.

- Properties: Specifies configuration options for your resource. Think of these as all the drop-down menus and checkbox options that you would see in the AWS console if you were to request the resource manually.

- Stack: A stack is a group of resources. These are the resources that you want to deploy, and that are specified in the YAML file.

## References

- syntax for a particular resource <https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html>
- The terminologies Template, and Stack <https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-whatis-concepts.html>
