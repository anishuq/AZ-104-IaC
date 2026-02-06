
Write-Host "Network Helper Loaded!"

function New-AzVNetSubnetsCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$subnetName,
        [string]$subnetPrefix     
    )
    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    } 

    #crete the subnetconfigs
    $subnetConfigObj = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetPrefix


    $VNetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $subnetConfigObj
        }

    #Create the VNet
    $vnetObj = New-AzVirtualNetwork @VNetParameters


    Write-Host "VNET obj type 1st time:  $($vnetObj.GetType().FullName)"

    <#
    Inbound Security Rules:
    ┌──────────────┬──────────┬────────────┬──────────┬──────────┐
    │ Priority     │ Name     │ Port       │ Protocol │ Action   │
    ├──────────────┼──────────┼────────────┼──────────┼──────────┤
    │ 300          │ AllowRDP │ 3389       │ TCP      │ Allow    │
    │ 310          │ AllowICMP│ *          │ ICMP     │ Allow    │
    │ 320          │ AllowHTTP│ 80         │ TCP      │ Allow    │
    └──────────────┴──────────┴────────────┴──────────┴──────────┘

    #>
    
    $rdpAllowRule = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" `
                                                    -Protocol Tcp -Direction Inbound `
                                                    -Priority 300 -SourceAddressPrefix * `
                                                    -SourcePortRange * -DestinationAddressPrefix * `
                                                    -DestinationPortRange 3389 `
                                                    -Access Allow    
    
    $icmpAllowRule = New-AzNetworkSecurityRuleConfig -Name "Allow-ICMP" `
                                                    -Protocol Icmp -Direction Inbound `
                                                    -Priority 310 -SourceAddressPrefix * `
                                                    -SourcePortRange * -DestinationAddressPrefix * `
                                                    -DestinationPortRange * `
                                                    -Access Allow

    $httpAllowRule = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" `
                                                    -Protocol Tcp -Direction Inbound `
                                                    -Priority 320 -SourceAddressPrefix * `
                                                    -SourcePortRange * -DestinationAddressPrefix * `
                                                    -DestinationPortRange 80 `
                                                    -Access Allow

    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName `
                                        -Location $Location `
                                        -Name "$($vnetName)-nsg" `
                                        -SecurityRules $rdpAllowRule, $icmpAllowRule, $httpAllowRule    

    Write-Host "VNET obj type 2nd time:  $($vnetObj.GetType().FullName)"
    #Associate NSG to subnet   
                 
    $vnetObj = Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetObj `
                            -Name $subnetName `
                            -AddressPrefix $vnetObj.Subnets[0].AddressPrefix `
                            -NetworkSecurityGroup $nsg

    $vnetObj = Set-AzVirtualNetwork -VirtualNetwork $vnetObj 
    #with out this line, the NSG is not associated to subnet. 
    #The output of above cmdlet needs to be saved back to vnetObj. 
    #Otherwise, System.Object[] is returned.

    Write-Host "VNET obj type 3rd time:  $($vnetObj.GetType().FullName)"
    return $vnetObj
}