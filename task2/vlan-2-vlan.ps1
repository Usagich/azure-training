Login-AzureRmAccount 

$resourceGroup = New-AzureRmResourceGroup -Name task2ResourceGroup -Location "West Europe"
$gatewaySubnet = New-AzureRmVirtualNetworkSubnetConfig -Name task2Gateway -AddressPrefix 192.168.100.0/28

New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup.ResourceGroupName -Name task2Vnet -AddressPrefix 192.168.0.0/16 -Subnet $gatewaySubnet -Location "West Europe"

$getVnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup.ResourceGroupName -Name task2Vnet
$getSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $gatewaySubnet.Name -VirtualNetwork $getVnet
$publicIpInterface = New-AzureRmPublicIpAddress -Name task2IP -ResourceGroupName $resourceGroup.ResourceGroupName -Location "West Europe" -AllocationMethod Dynamic
$ipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name task2IPConfig -Subnet $gatewaySubnet -PrivateIpAddress $publicIpInterface

New-AzureRmVirtualNetworkGateway -Name task2Gateway -ResourceGroupName $resourceGroup.ResourceGroupName -Location "West Europe" -IpConfigurations $ipconfig -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard

$signerCert = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=task2RootCertificate" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign
New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=task2ClientCertificate" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -Signer $signerCert -TextExtension @("2.5.29.39={text}1.3.6.1.5.5.7.3.2")

$rootCertificateName = "task2RootCert.cer"
$certificateFilePath = "C:\task2RootCert.cer"
$certificate = New-Object System.Security.Cryptography.X509Certificate2($certificateFilePath)
$certificateConvertToBase64 = [system.convert]::ToBase64String($cert.RawData)

$getGatewaySubnet = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $resourceGroup.ResourceGroupName -Name task2Gateway
$VPNClientIPPool = "172.16.201.0/24"

$getGatewaySubnet.BgpSettings -$null

Set-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $getGatewaySubnet -VpnClientAddressPool $VPNClientIPPool 
Add-AzureRmVpnClientRootCertificate -VpnClientRootCertificateName $rootCertificateName -VirtualNetworkGatewayName $getGatewaySubnet.Name -ResourceGroupName $resourceGroup.ResourceGroupName -PublicCertData $certificateConvertToBase64
Get-AzureRmVpnClientPackage -ResourceGroupName $resourceGroup.ResourceGroupName -VirtualNetworkGatewayName $getGatewaySubnet.Name -ProcessorArchitecture Amd64