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
        Size              = "Standard_B1s"
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
        $vmParameters["PublicIpAddress"] = $publicIP
        $vmParameters["OpenPorts"] = 3389,22

        #create the jumpbox vm
        New-AzVM @vmParameters 

        $fqdn = $publicIP.DnsSettings.Fqdn

        Write-Host "The FQDN for Jumpbox is $($fqdn)" -ForegroundColor Cyan
    }
    else {
    Write-Host "Public IP not needed. We will create 3 web servers here in a loop. These will NOT have public IPs." -ForegroundColor Yellow
    
}

    #print the vm parameters ports for debugging
    Write-Host "VM parameter Ports: $($vmParameters["OpenPorts"].Count)"
    Write-Host "VM parameter 1st Port: $($vmParameters["OpenPorts"][0])"
    Write-Host "VM parameter 2nd Port: $($vmParameters["OpenPorts"][1])"
    #to be deleted after debugging


}