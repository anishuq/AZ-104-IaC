Write-Host "VM Helper Loaded!"

function New-AzVMInstanceCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$VMName,
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$VnetObj,
        [System.Management.Automation.PSCredential] $Credential
    )

    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key]) and Type: $($PSBoundParameters[$key].GetType().Name)"
    }
    Write-Host "DEBUG: the VNet $($VnetObj.Name) with Prefix $($VnetObj.AddressSpace.AddressPrefixes)"
    
    Write-Host "First Subnet Name: $($VnetObj.Subnets[0].Name)"
    Write-Host "First Subnet Prefix: $($VnetObj.Subnets[0].AddressPrefix)"
    
    $VMParameters = @{ 
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        Name              = $VMName
        VirtualNetworkName= $VnetObj.Name
        SubnetName        = $VnetObj.Subnets[0].Name
        SubnetAddressPrefix = $VnetObj.Subnets[0].AddressPrefix[0]
        PublicIpAddressName = "MonitorServerPip" #this needs to be tested.
        OpenPorts         = 3389
        Credential        = $Credential
        }

    #Create the VM
    $vmObj = New-AzVM @VMParameters

    return $vmObj    
}