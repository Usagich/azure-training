param
(
    [string] $resourceGroupName = "task4RG",
    [string] $subscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $storageAccountName = "naliaksandra",
    [string] $containerName = "templates",
    [string] $templateURL = "https://naliaksandra.blob.core.windows.net/templates/init.json",
    [string] $resourceGroupStorage = "task3RG"
)

Login-AzureRmAccount 
Set-AzureRmContext -SubscriptionId $subscriptionId 

##resource group creation
New-AzureRmResourceGroup -Name $resourceGroupName -Location "West Europe"

####vault creation
$vaultName = "VMPasswordVault"
$passwordVM = "qqq111QQQ111"

New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -Location "West Europe" -EnabledForTemplateDeployment
Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"
$secretValue = ConvertTo-SecureString $passwordVM -AsPlainText -Force
Set-AzureRKeyVaultSecret -VaultName $vaultName -Name "secret" -SecretValue $secretValue


#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupStorage -Name $storageAccountName 
$subscriptionName = (Get-AzureRmSubscription -SubscriptionId $subscriptionId).Name
Set-AzureRmContext -Subscription $subscriptionName
#$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourseGroupName -Name $storageAccountName).Value[0]
$context = $storageAccount.Context
####upload file to blob container
$filePath = "D:\azure_training\azure-training\task4\init.json", "D:\azure_training\azure-training\task4\vmdeploy.json", "D:\azure_training\azure-training\task4\vmdeploy.parameters.json"
foreach ($path in $filePath)
{
    $fileName = $path.Split('\')[-1]
    Set-AzureStorageBlobContent -File $path -Container $containerName -Blob $fileName -Context $context
}



#####run template
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateURL