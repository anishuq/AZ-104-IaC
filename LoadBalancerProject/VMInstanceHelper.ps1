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
        $jumpBoxVmParameters["PublicIpAddress"] = $publicIP
        $jumpBoxVmParameters["OpenPorts"] = 3389,22

        #create the jumpbox vm
        New-AzVM @jumpBoxVmParameters 
        Write-Host "Created Jumpbox VM: $Vmname" -ForegroundColor Green
        $fqdn = $publicIP.DnsSettings.Fqdn

        Write-Host "The FQDN for Jumpbox is $($fqdn)" -ForegroundColor Cyan
    }
    else {

    Write-Host "Public IP not needed. We will create 3 web servers here in a loop. These will NOT have public IPs." -ForegroundColor Yellow


    for($i=1; $i -le 3; $i++){
        #create web server NIC without public IP
        $nic = New-AZNicWithoutPublicIP -NicName ("webserver-nic0" + $i) `
        -VNetName $VNetName -SubnetName $SubnetName `
        -ResourceGroupName $ResourceGroupName -Location $Location `
        -ErrorAction Stop

       #Then we set the name and open ports
        $webVmName = "webserver-vm0$i"
        # 2. Build the Config Object
        # New-AzVMConfig ONLY takes Name and Size
        $webVMConfigObj = New-AzVMConfig -VMName $webVmName -VMSize "Standard_B1s"

        
        # 3. Add the NIC to the Config
        $webVMConfigObj = Add-AzVMNetworkInterface -VM $webVMConfigObj -Id $nic.Id

        $publisher, $offer, $sku, $version = $Image.Split(":") 
        $webVMConfigObj = Set-AzVMSourceImage -VM $webVMConfigObj `
        -PublisherName $publisher `
        -Offer $offer `
        -Skus $sku `
        -Version $version

        # Linux OS config 
        $webVMConfigObj = Set-AzVMOperatingSystem -VM $webVMConfigObj -Linux `
        -ComputerName $webVmName `
        -Credential $Credential `
        -DisablePasswordAuthentication $false

        

        #create the web server vm
        New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $webVMConfigObj
        
        Write-Host "Created web server VM: $webVmName" -ForegroundColor Green
        break; #to prevent multiple vm creation during testing
    }
    
}

}



function New-AZNicWithoutPublicIP{
    param (
        [string]$NicName,
        [string]$VNetName,
        [string]$SubnetName,
        [string]$ResourceGroupName,
        [string]$Location
    )

    #Get the subnet
    $vnetObj = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
    $subnetObj = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnetObj 

    #Create the NIC without public IP
    $nic = New-AzNetworkInterface -Name $NicName -ResourceGroupName $ResourceGroupName `
    -Location $Location -SubnetId $subnetObj.Id -ErrorAction Stop

    return $nic
}