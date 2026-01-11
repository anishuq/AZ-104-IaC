Write-Host "Network Helper Loaded!"


function New-AzVNetSubnetCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$jumpboxSubnetName,
        [string]$jumpboxAddressPrefix,
        [string]$webSubnetName,
        [string]$webAddressPrefix
    )
    Write-Host "Creating VNet and Subnets: $($ResourceGroupName), $($Location), $($vnetName), $($jumpboxSubnetName), $($jumpboxAddressPrefix), $($webSubnetName), $($webAddressPrefix)"
    #crete the subnetconfigs
    
    $jumpboxSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $jumpboxSubnetName `
    -AddressPrefix $jumpboxAddressPrefix

    $webSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $webSubnetName `
    -AddressPrefix $webAddressPrefix

    #webserver rule config
    $webserverRuleConfig = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP-Inbound" `
    -Description "Allow HTTP Inbound only from Internet" `
    -Access "Allow" -Protocol "Tcp" -Direction "Inbound" `
    -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" `
    -DestinationAddressPrefix "*" -DestinationPortRange 80

    #create the nsg
    $webNSG = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName `
    -Location $Location -Name "webNSG" -SecurityRules $webserverRuleConfig

    #assign nsg to web subnet
    $webSubnetConfig.NetworkSecurityGroup = $webNSG

    $VnetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $jumpboxSubnetConfig, $webSubnetConfig
    }
    #create the VNET   
    $vnetObj = New-AzVirtualNetwork @VnetParameters

}