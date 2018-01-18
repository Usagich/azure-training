Login-AzureRmAccount

New-AzureRmResourceGroup -Name examplegroup -Location "West Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName examplegroup -TemplateFile init.json

#https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-create-first-template