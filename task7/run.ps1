﻿param
(
    [string] $ResourceGroupName = "task7RG",
    [string] $subscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $storageAccountName = "naliaksandra",
    [string] $containerTemplates = "templates",
    [string] $containerModules = "modules",
    [string] $templateURL1 = "https://naliaksandra.blob.core.windows.net/templates/KeyInit5.json",
    [string] $templateURL2 = "https://naliaksandra.blob.core.windows.net/templates/VMinit5.json",
    [string] $resourceGroupStorage = "storage",
    [string] $automationAccountName = "task7AA"
)

Login-AzureRmAccount 
Set-AzureRmContext -SubscriptionId $SubscriptionId

##resource group creation
New-AzureRmResourceGroup -Name $ResourceGroupName -Location "West Europe"


#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupStorage -Name $StorageAccountName 
$subscriptionName = (Get-AzureRmSubscription -SubscriptionId $SubscriptionId).Name
Set-AzureRmContext -Subscription $subscriptionName
$context = $storageAccount.Context
####upload files to blob container
$filePath = Get-ChildItem -Path "./" -Filter "*.json"
foreach ($path in $filePath.Name)
{
    $fileName = $path.Split('\')[-1]
    Set-AzureStorageBlobContent -File $path -Container $ContainerTemplates -Blob $fileName -Context $context -Force
}
Set-AzureStorageBlobContent -File TestConfig.ps1 -Container $ContainerModules -Blob TestConfig.ps1 -Context $context -Force
Set-AzureStorageBlobContent -File task5GraphRunbook.graphrunbook -Container $ContainerModules -Blob task5GraphRunbook.graphrunbook -Context $context -Force

#generate SAS
$startTime = (Get-Date).ToUniversalTime()
$expirationTime = $startTime.AddDays(2)
$sas = $context | New-AzureStorageContainerSASToken -Container $ContainerTemplates -Permission rwdl -Protocol HttpsOrHttp -StartTime $startTime -ExpiryTime $expirationTime


#####run template
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL1 -sas $sas -Force
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL2 -sas $sas -guid1 (new-guid) -guid2 (new-guid)


######run DSC
$namesDSC = Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

foreach ($node in $namesDSC)
{
    Register-AzureRmAutomationDscNode -AzureVMName $node.Name.Split('.')[-1] -NodeConfigurationName $node.Name -ResourceGroupName $ResourceGroupName -AutomationAccountName $automationAccountName

}

##### and runbook
Start-AzureRmAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name task5GraphRunbook


Here is MFU related to 7th task:
1.	Watch demo 
2.	Try to reproduce all steps manually
3.	Create ARM template which should do the same what was described in demo.
a.	Do not forget to use template reference documentation
b.	You can also find some useful info here
4.	Restore VMs disks to another storage account ( via PowerShell commandlets) with original names of disks:
a.	By default each recovered disk is located on targeted storage account in separate container and named not like original vhd. You have to review all concomitant json files in specified container to find out the necessary details.