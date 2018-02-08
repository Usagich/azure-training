param
(
    [string] $ResourceGroupName = "task88RG",
    [string] $SubscriptionId = "b1d40bc1-2977-4394-b374-fe62498046e2",
    [string] $StorageAccountName = "naliaksandra",
    [string] $ContainerTemplates = "templates",
    [string] $TemplateURL1 = "https://naliaksandra.blob.core.windows.net/templates/template.json",
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

#generating SAS
$startTime = (Get-Date).ToUniversalTime()
$expirationTime = $startTime.AddDays(2)
$sas = $context | New-AzureStorageContainerSASToken -Container $ContainerTemplates -Permission rwdl -Protocol HttpsOrHttp -StartTime $startTime -ExpiryTime $expirationTime

#####run template
##first app
$timestamp1 = (Get-Date).Millisecond
##generating unique app name
$appname1 = "task6app${timestamp1}"
$location1 = "Central US"
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL1 -sas $sas `
                                                                           -appServicePlan "task6AppSP1" `
                                                                           -location $location1 `
                                                                           -appName $appname1 `
                                                                           -webConfigName "web" `
                                                                           -appHostName "${appname1}.azurewebsites.net" `
                                                                           -trafficManagerName "task6TM"

$timestamp2 = (Get-Date).Millisecond
##generating unique app name
$appname2 = "task6app${timestamp2}"
$location2 = "West Europe"
##second app
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL1 -sas $sas `
                                                                           -appServicePlan "task6AppSP2" `
                                                                           -location $location2 `
                                                                           -appName $appname2 `
                                                                           -webConfigName "web" `
                                                                           -appHostName "${appname2}.azurewebsites.net" `
                                                                           -trafficManagerName "task6TM"

##traffic manager
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateURL2 `
                                                                           -trafficManagerName "task6TM" `
                                                                           -azureEndpoint1 "task6AzEndpoint1" `
                                                                           -externalEndpoint1 "task6ExtEndpoint1" `
                                                                           -azureEndpoint2 "task6AzEndpoint2" `
                                                                           -externalEndpoint2 "task6ExtEndpoint2" `
                                                                           -location1 $location1 `
                                                                           -location2 $location2 `
                                                                           -appName1 $appname1 `
                                                                           -appName2 $appname2
