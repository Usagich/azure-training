﻿Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId "b1d40bc1-2977-4394-b374-fe62498046e2" 


New-AzureRmResourceGroup -Name task3RG -Location "West Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName task3RG -TemplateFile "D:\azure_training\azure-training\task3\init.json" -TemplateParameterFile "D:\azure_training\azure-training\task3\init.parameters.json" 