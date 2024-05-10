# Infrastructure as Code

This repository contains the code for the infrastructure as code (IaC) for the project.

## Go to iac folder

```sh
cd iac
```

## CloudFormation

Create stack:

```sh
aws cloudformation create-stack --stack-name my-stack --region eu-west-1 --template-body file://vpc.yml
```

- powershell: `.\create.ps1 "my-stack"  "vpc.yml" "vps-parameters.json"`
- bash: `./create.sh "my-stack"  "vpc.yml" "vps-parameters.json"`

Update stack:

```sh
aws cloudformation update-stack --stack-name my-stack --region eu-west-1 --template-body file://vpc.yml
```

Describe stack:

```sh
aws cloudformation describe-stacks --stack-name my-stack --region eu-west-1
```

### Glossary in CloudFormation scripts

- Name: A name you want to give to the resource (does this have to be unique across all resource types?)

- Type: Specifies the actual hardware resource that you’re deploying.

- Properties: Specifies configuration options for your resource. Think of these as all the drop-down menus and checkbox options that you would see in the AWS console if you were to request the resource manually.

- Stack: A stack is a group of resources. These are the resources that you want to deploy, and that are specified in the YAML file.

### References

- syntax for a particular resource <https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html>
- The terminologies Template, and Stack <https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-whatis-concepts.html>
