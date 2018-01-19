Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId "b1d40bc1-2977-4394-b374-fe62498046e2" 


New-AzureRmResourceGroup -Name examplegroup -Location "West Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName examplegroup -TemplateFile init.json