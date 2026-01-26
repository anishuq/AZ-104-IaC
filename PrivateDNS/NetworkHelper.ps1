. "$PSScriptRoot\PrivateDNSHelper.ps1"
. "$PSScriptRoot\VMInstanceHelper.ps1"

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

    Write-Host "We want to know the full type name of the VNET obj: $($DemoVNet2Obj.GetType().FullName)"

    #create 2 VMs in these 2 VNETS
    $Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
    $username = "admanisulhuq" #enter username for all VM
    $plainPassword = "McIe@4-5WmFvM" #enter password for VM
    $password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
    $vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)

    New-AzVMCreation -pipName "pip" -EnablePublicIP $true -Vmname "demovnet1vm01" -VNetName $vnetName1 `
        -SubnetName $subnet.Name -ResourceGroupName $ResourceGroupName -Location $Location `
        -Image $Image -Credential $vmcred

    New-AzVMCreation -pipName "" -EnablePublicIP $false -Vmname "demovnet2vm01" -VNetName $vnetName2 `
        -SubnetName $subnet2.Name -ResourceGroupName $ResourceGroupName -Location $Location `
        -Image $Image -Credential $vmcred


    #sending VNET onjects and link private zones
    New-AzPrivateDNSZoneCreation -ResourceGroupName $ResourceGroupName -Location $Location `
    -vnetObj1 $DemoVNet1Obj -vnetObj2 $DemoVNet2Obj -zoneName "anisulprivatezone.com"
}