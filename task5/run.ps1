param
(
    [string] $ResourceGroupName = "task5RG",
    [string] $subscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $storageAccountName = "naliaksandra",
    [string] $containerTemplates = "templates",
    [string] $containerModules = "modules",
    [string] $templateURL1 = "https://naliaksandra.blob.core.windows.net/templates/KeyInit5.json",
    [string] $templateURL2 = "https://naliaksandra.blob.core.windows.net/templates/VMinit5.json",
    [string] $resourceGroupStorage = "storage",
    [string] $automationAccountName = "task5AA"
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