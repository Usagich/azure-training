param
(
    [string] $ResourceGroupName = "task7RG",
    [string] $SubscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $StorageAccountName = "naliaksandra",
    [string] $ContainerTemplates = "templates",
    [string] $ContainerModules = "modules",
    [string] $TemplateURL1 = "https://naliaksandra.blob.core.windows.net/templates/KeyInit7.json",
    [string] $TemplateURL2 = "https://naliaksandra.blob.core.windows.net/templates/VMinit7.json",
    [string] $TemplateURL3 = "https://naliaksandra.blob.core.windows.net/templates/BackupInit7.json",
    [string] $TemplateURL4 = "https://naliaksandra.blob.core.windows.net/templates/emailsNoification.json",
    [string] $ResourceGroupStorage = "storage"
)


Login-AzureRmAccount 
Set-AzureRmContext -SubscriptionId $SubscriptionId

##resource group creation
New-AzureRmResourceGroup -Name $ResourceGroupName -Location "West Europe" -Force


#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupStorage -Name $StorageAccountName 
$context = $storageAccount.Context

####upload files to blob container
$filePath = Get-ChildItem -Path "./" -Filter "*.json"
foreach ($path in $filePath.Name)
{

     $fileName = $path.Split('\')[-1]
     Set-AzureStorageBlobContent -File $path -Container $ContainerTemplates -Blob $fileName -Context $context -Force
}

#generate SAS
$startTime = (Get-Date).ToUniversalTime()
$expirationTime = $startTime.AddDays(2)
$sas = $context | New-AzureStorageContainerSASToken -Container $ContainerTemplates -Permission rwdl -Protocol HttpsOrHttp -StartTime $startTime -ExpiryTime $expirationTime

#####run template
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL1 -sas $sas -Force
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL2 -sas $sas 
while((Get-AzureRmVM -ResourceGroupName $ResourceGroupName).ProvisioningState -notlike "Succeeded")
{
    sleep 15
}
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL3 -sas $sas 
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL4

##set RSB context
$vaultName = Get-AzureRmRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name "task7BSV"
$backupContext = Set-AzureRmRecoveryServicesVaultContext -Vault $vaultName

##do backup
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -FriendlyName "task7VM" 
$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType AzureVM 
Backup-AzureRmRecoveryServicesBackupItem -Item $item

##wait for backup is done
while ((Get-AzureRmRecoveryServicesBackupJob)[0].EndTime -eq $null)
{
    sleep (15)
}

Write-Host "Backup is done!"


##restore backup
$container = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -FriendlyName "task7VM"
$backupItem = Get-AzureRmRecoveryServicesBackupItem -WorkloadType AzureVM -Container $container
$startDate = (Get-Date).AddDays(-7).ToUniversalTime()
$endDate = (Get-Date).ToUniversalTime()
$recoveryPoint = Get-AzureRmRecoveryServicesBackupRecoveryPoint -Item $backupItem -StartDate $startDate.ToUniversalTime() -EndDate $endDate.ToUniversalTime() 
Restore-AzureRmRecoveryServicesBackupItem -RecoveryPoint $recoveryPoint[0] -StorageAccountName $StorageAccountName -StorageAccountResourceGroupName $ResourceGroupStorage

##wait for restore is done
while ((Get-AzureRmRecoveryServicesBackupJob)[0].EndTime -eq $null)
{
    sleep (15)
}

Write-Host "starting to move backup with new name"

##creating storage account context
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupStorage -Name $StorageAccountName).Value[0]
$storageContext = New-AzureStorageContext -StorageAccountName  $StorageAccountName -StorageAccountKey $storageAccountKey

##getting name of vhd container
$diskContainer = (Get-AzureStorageContainer -Context $storageContext)[-1].Name
##getting list of blobs in container
$blobList = Get-AzureStorageBlob -Context $storageContext -Container $diskContainer

##download json to home path
$destinationPath = ".\vmconfig.json"
foreach ($blob in $blobList)
{
    if( $blob.Name -like "*.json")
    {
        $blobName = $blob.Name
    }
}
Get-AzureStorageBlobContent -Container $diskContainer -Blob $blobName -Destination $destinationPath -Context $storageContext

##getting NAME parameter from json
Get-Content $destinationPath -Encoding Byte | ? {$_ -ne 0x00} | Set-Content temp.txt -Encoding Byte
$jsonContent = (Get-Content -Encoding Ascii temp.txt) | ConvertFrom-Json

$diskName = $jsonContent."properties.storageProfile".osDisk.name

##creating new container for renamed vhd 
New-AzureStorageContainer -Name vhd -Permission Blob -Context $storageContext
##getting vhd name
foreach ($blob in $blobList)
{
    if( $blob.Name -like "*.vhd")
    {
        $blobName = $blob.Name
    }
}
##copying vhd to new container with new name
Start-AzureStorageBlobCopy -SrcContainer $diskContainer -DestContainer vhd -SrcBlob $blobName -DestBlob $diskName -Context $storageContext -DestContext $storageContext 
##deleting old container
Remove-AzureStorageContainer -Name $diskContainer -Force -Context $storageContext
Remove-AzureStorageBlob -Container $diskContainer -Context $storageContext -Blob $blobName 
Remove-Item temp.txt
Remove-Item $destinationPath
 
Write-Host "Restoring is done! Now you can check storage account 'naliaksandra'"