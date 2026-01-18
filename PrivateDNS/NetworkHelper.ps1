Write-Host "Network Helper Loaded!"


function New-AzVNetsCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName1,
        [string]$vnetAddressPrefix1,
        [string]$vnetName2,
        [string]$vnetAddressPrefix2       
    )
    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    }
      
    #crete the subnetconfigs
    $subnet = New-AzVirtualNetworkSubnetConfig -Name "Default_Subnet1" -AddressPrefix "10.0.1.0/24"
    $DemoVNet1Parameters = @{
        Name              = $vnetName1
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix1
        Subnet            = $subnet
        }    

    #create the VNET   
    $DemoVNet1Obj = New-AzVirtualNetwork @DemoVNet1Parameters

    $subnet2 = New-AzVirtualNetworkSubnetConfig -Name "Default_Subnet2" -AddressPrefix "192.168.1.0/24"
    $DemoVNet2Parameters = @{
        Name              = $vnetName2
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix2
        Subnet            = $subnet2
    }    

    #create the VNET   
    $DemoVNet2Obj = New-AzVirtualNetwork @DemoVNet2Parameters

}