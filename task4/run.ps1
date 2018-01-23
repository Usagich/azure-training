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
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "https://raw.githubusercontent.com/Usagich/azure-training/master/task4/init.json"


#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName 
$subscriptionName = (Get-AzureRmSubscription -SubscriptionId $subscriptionId).Name
Set-AzureRmContext -Subscription $subscriptionName
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourseGroupName -Name $storageAccountName).Value[0]

$ctx = $storageAccount.Context
####upload zip to blob container
Set-AzureStorageBlobContent -File $moduleZipDestinationPath -Container $containerName -Blob $moduleZipDestinationPath -Context $ctx 


######publish module to Azure Automation
New-AzureRmAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $moduleName -ContentLink $moduleURL
######################


############testing 
Set-AzureRmVMCustomScriptExtension -ResourceGroupName $resourceGroupName -VMName "task4VM" -Name "IISInstallConfiguration" `
    -FileUri "https://naliaksandra.blob.core.windows.net/modules/IISInstallConfiguration.ps1" -Run "IISInstallConfiguration.ps1" -Location "West Europe"