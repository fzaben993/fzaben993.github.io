param (
    [string]$stackName,
    [string]$templateFile,
    [string]$parametersFile
)

$region = "eu-west-1"

aws cloudformation update-stack `
    --stack-name $stackName `
    --template-body file://$templateFile `
    --parameters file://$parametersFile `
    --region $region

