Write-Host "VM Instance Helper Loaded!"


function New-AzVMCreation{
    param (
        [string]$pipName,
        [boolean]$EnablePublicIP,
        [string]$Vmname,
        [string]$VNetName,
        [string]$SubnetName,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$Image,
        [System.Management.Automation.PSCredential] $Credential 
    )


    #common VM parameters
    $jumpBoxVmParameters = @{
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

    if($EnablePublicIP -eq $true){
        #create the public ip
        $publicIP = New-AzPublicIpAddress -Name $pipName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -AllocationMethod Static `
        -Sku Basic `
        -DomainNameLabel ($Vmname + "-webserveradmin") `
        -ErrorAction Stop

        #add public ip to vm parameters
        $jumpBoxVmParameters["PublicIpAddress"] = $publicIP
        $jumpBoxVmParameters["OpenPorts"] = 3389,22

        #create the jumpbox vm
        New-AzVM @jumpBoxVmParameters 
        Write-Host "Created Jumpbox VM: $Vmname" -ForegroundColor Green

        $fqdn = $publicIP.DnsSettings.Fqdn

        Write-Host "The FQDN for Jumpbox is $($fqdn)" -ForegroundColor Cyan
    }

}



