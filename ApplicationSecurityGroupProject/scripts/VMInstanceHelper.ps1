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

    if($EnablePublicIP -eq $true){
        #create the public ip
        $publicIP = New-AzPublicIpAddress -Name "WebVMPIP" -ResourceGroupName $ResourceGroupName `
                    -Location $Location -AllocationMethod Static -Sku Standard -ErrorAction Stop

        #add public ip to vm parameters
        $vmParameters["PublicIpAddress"] = $publicIP
        <#>
            $vmParameters["OpenPorts"] = 3389,22 ... we are going to omit this.
        Because using -OpenPorts 3389,22 on New-AzVM (simplified parameter set) 
        auto-creates a second, NIC-level NSG separate from NSG1 (we are going to create
        this at the SUBNET level). We want the rules in NSG1 to solely govern the traffic to the VM. 
        If we use -OpenPorts, then we will have two NSGs governing traffic to the VM, 
        which is not what we want. 
        #>

        #create the vm with PIP
        New-AzVM @vmParameters 
        Write-Host "Created VM with PIP: $Vmname" -ForegroundColor Green
    }
    else{
        New-AzVM @vmParameters 
        Write-Host "Created VM without PIP: $Vmname" -ForegroundColor Green
    }
}



