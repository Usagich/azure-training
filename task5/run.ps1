param
(
    [string] $resourceGroupName = "task5RG",
    [string] $subscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $storageAccountName = "naliaksandra",
    [string] $containerName = "templates",
    [string] $templateURL = "https://naliaksandra.blob.core.windows.net/templates/init5.json",
    [string] $resourceGroupStorage = "storage",
    [string] $automationAccountName = "task5AA"
)

Login-AzureRmAccount 
Set-AzureRmContext -SubscriptionId $subscriptionId

##resource group creation
New-AzureRmResourceGroup -Name $resourceGroupName -Location "West Europe"

####vault for VM creation
$vaultName = "VMPasswordVault"
$passwordVM = "qqq111QQQ111"

New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -Location "West Europe" -EnabledForTemplateDeployment
Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"
$secretValue = ConvertTo-SecureString $passwordVM -AsPlainText -Force

#sorry, but you should manually add your access permissions here: 
#https://portal.azure.com/#resource/subscriptions/b1d40bc1-2977-4394-b374-fe62498046e2/resourceGroups/task5RG/providers/Microsoft.KeyVault/vaults/VMPasswordVault/access_policies
#then you can create a secret
Set-AzureKeyVaultSecret -VaultName $vaultName -Name "secret" -SecretValue $secretValue

####vault for Automation Account creation
$vaultName = "AAPasswordVault"
$passwordVM = "Fafo7145"

New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -Location "West Europe" -EnabledForTemplateDeployment
Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"
$secretValue = ConvertTo-SecureString $passwordVM -AsPlainText -Force

#sorry, but you should manually add your access permissions here: 
#https://portal.azure.com/#resource/subscriptions/b1d40bc1-2977-4394-b374-fe62498046e2/resourceGroups/task5RG/providers/Microsoft.KeyVault/vaults/AAPasswordVault/access_policies
#then you can create a secret
Set-AzureKeyVaultSecret -VaultName $vaultName -Name "autopass" -SecretValue $secretValue

#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupStorage -Name $storageAccountName 
$subscriptionName = (Get-AzureRmSubscription -SubscriptionId $subscriptionId).Name
Set-AzureRmContext -Subscription $subscriptionName
$context = $storageAccount.Context
####upload file to blob container
$filePath = ".\init5.json", ".\vmdeploy5.json", ".\vmdeploy5.parameters.json"
foreach ($path in $filePath)
{
    $fileName = $path.Split('\')[-1]
    Set-AzureStorageBlobContent -File $path -Container $containerName -Blob $fileName -Context $context
}


#####run template
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateURL


$cred = Get-AzureRmAutomationCredential -AutomationAccountName $automationAccountName -Name task5cred -ResourceGroupName task5RG
Get-AzureRmContext -

######run runbook
