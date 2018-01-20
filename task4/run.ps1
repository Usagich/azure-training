$resourceGroupName = "task4RG"

Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId "b1d40bc1-2977-4394-b374-fe62498046e2" 


New-AzureRmResourceGroup -Name $resourceGroupName -Location "West Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "https://raw.githubusercontent.com/Usagich/azure-training/master/task4/init.json"
