param
(
    [string] $resourceGroupName = "task5RG",
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
Set-AzureRmContext -SubscriptionId $subscriptionId

##resource group creation
New-AzureRmResourceGroup -Name $resourceGroupName -Location "West Europe"


#####deploy to azure blob
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupStorage -Name $storageAccountName 
$subscriptionName = (Get-AzureRmSubscription -SubscriptionId $subscriptionId).Name
Set-AzureRmContext -Subscription $subscriptionName
$context = $storageAccount.Context
####upload files to blob container
$filePath = Get-ChildItem -Path "./" -Filter "*.json"
foreach ($path in $filePath.Name)
{
    $fileName = $path.Split('\')[-1]
    Set-AzureStorageBlobContent -File $path -Container $containerTemplates -Blob $fileName -Context $context -Force
}
Set-AzureStorageBlobContent -File TestConfig.ps1 -Container $containerModules -Blob TestConfig.ps1 -Context $context -Force
Set-AzureStorageBlobContent -File task5GraphRunbook.graphrunbook -Container $containerModules -Blob task5GraphRunbook.graphrunbook -Context $context -Force

#generate SAS
$startTime = (Get-Date).ToUniversalTime()
$expirationTime = $startTime.AddDays(2)
$sas = $context | New-AzureStorageContainerSASToken -Container $containerTemplates -Permission rwdl -Protocol HttpsOrHttp -StartTime $startTime -ExpiryTime $expirationTime


#####run template
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateURL1 -sas $sas -Force
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateURL2 -sas $sas


######run DSC
Start-AzureRmAutomationDscCompilationJob -ConfigurationName TestConfig -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName
$namesDSC = Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName

####nononononono
Start-AzureRmAutomationDscNodeConfigurationDeployment -NodeConfigurationName $namesDSC[0].Name -NodeName $namesDSC[0].Name.Split('.')[-1] -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName
Start-AzureRmAutomationDscNodeConfigurationDeployment -NodeConfigurationName $namesDSC[1].Name -NodeName $namesDSC[1].Name.Split('.')[-1] -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName

Get-AzureRmAutomationDscNodeConfigurationDeployment -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName


##### and runbook
Start-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name task5GraphRunbook


