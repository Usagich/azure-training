param
(
    [string] $resourseGroupName = "task4RG",
    [string] $automationAccountName = "task4AA",
    [string] $subscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $moduleURL = "https://naliaksandra1.blob.core.windows.net/modules/task4.zip",
    [string] $moduleName = "task4",
    [string] $moduleLocalPath = "D:\azure_training\azure-training\task4",
    [string] $moduleZipDestinationPath = "task4.zip",
    [string] $storageAccountName = "naliaksandra",
    [string] $containerName = "modules"
)

Login-AzureRmAccount 
Set-AzureRmContext -SubscriptionId $subscriptionId 


New-AzureRmResourceGroup -Name $resourceGroupName -Location "West Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "https://raw.githubusercontent.com/Usagich/azure-training/master/task4/init.json"

####zip module
Compress-Archive -Path $moduleLocalPath -DestinationPath $moduleZipDestinationPath"\task4" -Force

#2.	Create a PS script which does the publishing for you.
#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourseGroupName -Name $storageAccountName 
$subscriptionName = (Get-AzureRmSubscription -SubscriptionId $subscriptionId).Name
Set-AzureRmContext -Subscription $subscriptionName
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourseGroupName -Name $storageAccountName).Value[0]

$ctx = $storageAccount.Context
####upload zip to blob container
Set-AzureStorageBlobContent -File $moduleZipDestinationPath -Container $containerName -Blob $moduleZipDestinationPath -Context $ctx 


######publish module to Azure Automation
New-AzureRmAutomationModule -ResourceGroupName $resourseGroupName -AutomationAccountName $automationAccountName -Name $moduleName -ContentLink $moduleURL
######################

#####configuration publishing and compilation 
Import-AzureRmAutomationDscConfiguration -AutomationAccountName $automationAccountName -ResourceGroupName $resourseGroupName -SourcePath $moduleLocalPath"\task4DSC.ps1" -Published -Force
Start-AzureRmAutomationDscCompilationJob -AutomationAccountName $automationAccountName -ResourceGroupName $resourseGroupName -ConfigurationName "task4DSC"

