Write-Host "Network Helper Loaded!"


function New-AzVNetSubnetCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$jumpboxSubnetName,
        [string]$jumpboxAddressPrefix,
        [string]$HelloSubnetName,
        [string]$HelloAddressPrefix,
        [string]$ByeSubnetName,
        [string]$ByeAddressPrefix
    )
    #print all the params
    <#
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    }
    #>  
    #crete the subnetconfigs
    
    $jumpboxSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $jumpboxSubnetName `
    -AddressPrefix $jumpboxAddressPrefix

    $helloSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $HelloSubnetName `
    -AddressPrefix $HelloAddressPrefix

    $byeSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $ByeSubnetName `
    -AddressPrefix $ByeAddressPrefix
    

    #webserver rule config
    $webserverRuleConfig = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP-Inbound" `
    -Description "Allow HTTP Inbound only from Internet into both Hello and Bye subnets" `
    -Access "Allow" -Protocol "Tcp" -Direction "Inbound" `
    -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" `
    -DestinationAddressPrefix "*" -DestinationPortRange 80

    #create the nsg and apply 
    $webHelloByeNSG = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName `
    -Location $Location -Name "webHelloByeNSG" -SecurityRules $webserverRuleConfig

    #assign nsg to 2 subnets.
    $helloSubnetConfig.NetworkSecurityGroup = $webHelloByeNSG
    $byeSubnetConfig.NetworkSecurityGroup = $webHelloByeNSG

    $VnetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $jumpboxSubnetConfig, $helloSubnetConfig, $byeSubnetConfig
    }    

    #create the VNET   
    $vnetObj = New-AzVirtualNetwork @VnetParameters

}