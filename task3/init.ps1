Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId "" 


New-AzureRmResourceGroup -Name task3RG -Location "West Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName task3RG -TemplateFile "https://raw.githubusercontent.com/Usagich/azure-training/master/task3/init.json"
