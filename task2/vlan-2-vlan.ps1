Login-AzureRmAccount 
Set-AzureRmContext -SubscriptionId "b1d40bc1-2977-4394-b374-fe62498046e2" 

#Get-AzureRmSubscription

$resourceGroup = New-AzureRmResourceGroup -Name task2ResourceGroup -Location "West Europe"
#Remove-AzureRmResourceGroup -Name task2ResourceGroup


$vnet1GatewaySubnetConfiguration = New-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 192.168.0.0/28
#Remove-AzureRmVirtualNetworkSubnetConfig -Name $vnet1GatewaySubnetConfiguration.Name
$vnet2GatewaySubnetConfiguration = New-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 172.16.0.0/28
#Remove-AzureRmVirtualNetworkSubnetConfig -Name $vnet2GatewaySubnetConfiguration.Name


$vnet1 = New-AzureRmVirtualNetwork -Name task2vnet1 -ResourceGroupName $resourceGroup.ResourceGroupName -AddressPrefix 192.168.0.0/24 -Subnet $vnet1GatewaySubnetConfiguration -Location "West Europe"
$vnet2 = New-AzureRmVirtualNetwork -Name task2vnet2 -ResourceGroupName $resourceGroup.ResourceGroupName -AddressPrefix 172.16.0.0/24 -Subnet $vnet2GatewaySubnetConfiguration -Location "West Europe"
#Remove-AzureRmVirtualNetwork -Name $vnet1.Name
#Remove-AzureRmVirtualNetwork -Name $vnet2.Name
$getSubnetConfiguration1 = Get-AzureRmVirtualNetworkSubnetConfig -Name $vnet1GatewaySubnetConfiguration.Name -VirtualNetwork $getVnet1
$getSubnetConfiguration2 = Get-AzureRmVirtualNetworkSubnetConfig -Name $vnet2GatewaySubnetConfiguration.Name -VirtualNetwork $getVnet2


$publicIpVlan1 = New-AzureRmPublicIpAddress -Name task2publIP1 -ResourceGroupName $resourceGroup.ResourceGroupName -Location "West Europe" -AllocationMethod Dynamic
$publicIpVlan2 = New-AzureRmPublicIpAddress -Name task2publIP2 -ResourceGroupName $resourceGroup.ResourceGroupName -Location "West Europe" -AllocationMethod Dynamic
#Remove-AzureRmPublicIpAddress -Name $publicIpVlan1.Name
#Remove-AzureRmPublicIpAddress -Name $publicIpVlan2.Name
$vpnIPconf1 = New-AzureRmVirtualNetworkGatewayIpConfig -Name task2vpnIPconf1 -Subnet $getSubnetConfiguration1 -PublicIpAddress $publicIpVlan1
$vpnIPconf2 = New-AzureRmVirtualNetworkGatewayIpConfig -Name task2vpnIPconf2 -Subnet $getSubnetConfiguration2 -PublicIpAddress $publicIpVlan2
#Remove-AzureRmVirtualNetworkGatewayIpConfig -Name $vpnIPconf1
#Remove-AzureRmVirtualNetworkGatewayIpConfig -Name $vpnIPconf2

$VPNsubnet1 = New-AzureRmVirtualNetworkGateway -Name task2VPNgateway1 -ResourceGroupName $resourceGroup.ResourceGroupName -Location "West Europe" -IpConfigurations $vpnIPconf1 -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard
$VPNsubnet2 = New-AzureRmVirtualNetworkGateway -Name task2VPNgateway2 -ResourceGroupName $resourceGroup.ResourceGroupName -Location "West Europe" -IpConfigurations $vpnIPconf2 -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard
#Remove-AzureRmVirtualNetworkGateway -Name $VPNsubnet1.Name
#Remove-AzureRmVirtualNetworkGateway -Name $VPNsubnet2.Name


New-AzureRmVirtualNetworkGatewayConnection -Name task2connection1to2 -ResourceGroupName $resourceGroup.ResourceGroupName -VirtualNetworkGateway1 $getVPNsubnet1 -VirtualNetworkGateway2 $getVPNsubnet2 -Location "West Europe" -ConnectionType Vnet2Vnet -SharedKey 'zaq123'
New-AzureRmVirtualNetworkGatewayConnection -Name task2connection2to1 -ResourceGroupName $resourceGroup.ResourceGroupName -VirtualNetworkGateway1 $getVPNsubnet2 -VirtualNetworkGateway2 $getVPNsubnet1 -Location "West Europe" -ConnectionType Vnet2Vnet -SharedKey 'zaq123'
#Remove-AzureRmVirtualNetworkGatewayConnection -Name task2connection1to2
#Remove-AzureRmVirtualNetworkGatewayConnection -Name task2connection2to1
