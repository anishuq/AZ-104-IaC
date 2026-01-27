Write-Host "VM instance Loaded!"

function New-AzVMInstanceCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$VMName,
        [object]$VNetName,
        [string]$SubnetName,
        [string]$Image,
        [System.Management.Automation.PSCredential] $Credential
    )

    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    } 

    #Define the VM configuration
    $vmParameters = @{
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        VirtualNetworkName= $VNetName
        SubnetName        = $SubnetName
        Name              = $Vmname
        Image             = $Image
        Size              = "Standard_D2s_v3"
        Credential        = $Credential
        ErrorAction      = "Stop"
    }

    $vmObj = New-AzVM @vmParameters

    Write-Host "VM obj type:  $($vmObj.GetType().FullName)"

    Write-Host "Change this VM's DNS settings to use Google's DNS server (8.8.8.8)"
    $nicObj = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $vmObj.Name
    $nicObj.DnsSettings.DnsServers.Add("8.8.8.8")
    Set-AzNetworkInterface -NetworkInterface $nicObj

    return $vmObj
}