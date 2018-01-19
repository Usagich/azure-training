Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId "b1d40bc1-2977-4394-b374-fe62498046e2" 


New-AzureRmResourceGroup -Name task3RG -Location "West Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName task3RG -TemplateFile "C:\Users\Usagi\Desktop\azure-training-master\azure-training-master\task3\init.json"