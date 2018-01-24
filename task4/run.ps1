param
(
    [string] $resourceGroupName = "task4RG",
    [string] $automationAccountName = "task4AA",
    [string] $subscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $moduleURL = "https://naliaksandra1.blob.core.windows.net/modules/task4DSC.zip",
    [string] $moduleName = "task4",
    [string] $moduleLocalPath = "D:\azure_training\azure-training\task4",
    [string] $moduleZipDestinationPath = "task4DSC.zip",
    [string] $storageAccountName = "naliaksandra",
    [string] $containerName = "modules"
)

##########Import-Module -Name Vagrant

Login-AzureRmAccount 
Set-AzureRmContext -SubscriptionId $subscriptionId 


New-AzureRmResourceGroup -Name $resourceGroupName -Location "West Europe"


$vaultName = "VMPasswordVault"
$passwordVM = "qqq111QQQ111"

New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -Location "West Europe" -EnabledForTemplateDeployment
Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"
$secretValue = ConvertTo-SecureString $passwordVM -AsPlainText -Force
Set-AzureRKeyVaultSecret -VaultName $vaultName -Name "secret" -SecretValue $secretValue


New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "https://naliaksandra.blob.core.windows.net/templates/init.json"








#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName 
$subscriptionName = (Get-AzureRmSubscription -SubscriptionId $subscriptionId).Name
Set-AzureRmContext -Subscription $subscriptionName
#$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourseGroupName -Name $storageAccountName).Value[0]
$ctx = $storageAccount.Context
####upload zip to blob container
Set-AzureStorageBlobContent -File $moduleZipDestinationPath -Container $containerName -Blob $moduleZipDestinationPath -Context $ctx 

