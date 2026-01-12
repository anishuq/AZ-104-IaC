Write-Host "Web Server Instance Helper Loaded!"

function New-AzWebServerCreation{
    param (
        [string]$AppName,
        [string]$VNetName,
        [string]$SubnetName,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$Image,
        [System.Management.Automation.PSCredential] $Credential 
    )

    <#Debug infoging purposes only#>
    Write-Host "All the parameters received in New-AzWebServerCreation function:" -ForegroundColor Cyan
    Write-Host "AppName: $AppName"
    Write-Host "VNetName: $VNetName"
    Write-Host "SubnetName: $SubnetName"
    Write-Host "ResourceGroupName: $ResourceGroupName"
    Write-Host "Location: $Location"
    Write-Host "Image: $Image"
    Write-Host "Credential UserName: $($Credential.UserName)"
    Write-Host "Credential Password: $($Credential.GetNetworkCredential().Password)"
    

    for($i=1; $i -le 3; $i++){
        <#We don't need public IP for web servers. We also don't need to create NSG
        rules separately as we have already associated NSG with the web subnet.
        #>
        $nic = New-AZNicWithoutPublicIP -NicName ("$($AppName)Server-nic0$i") `
            -VNetName $VNetName -SubnetName $SubnetName `
            -ResourceGroupName $ResourceGroupName -Location $Location `
            -ErrorAction Stop
        
        #At the beginning we are not going to use the NIC created above.

        $Vmname = "$($AppName)Server-vm0$i" #placeholder name, will be changed in loop
        $vmConfig = New-AzVMConfig -VMName $Vmname -VMSize "Standard_B1s" 
        
        $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig `
        -Linux `
        -ComputerName $Vmname `
        -Credential $Credential

        # 2. THE FIX: Explicitly disable the Security Profile
        # This stops the 'Standard' securityType error from being triggered
        $vmConfig.SecurityProfile = $null

        #Our image is ---> "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"

        # Split the string by the colon
        $parts = $Image.Split(":")

        # Assign to descriptive variables
        $publisher = $parts[0]  # Canonical
        $offer     = $parts[1]  # 0001-com-ubuntu-server-jammy
        $sku       = $parts[2]  # 22_04-lts
        $version   = $parts[3]  # latest
        
        
        $vmConfig = Set-AzVMSourceImage -VM $vmConfig `
        -PublisherName $publisher `
        -Offer $offer `
        -Sku $sku `
        -Version $version
        
        #Lets add a NIC and see what happens.
        $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

        New-AzVM -VM $vmConfig -ResourceGroupName $ResourceGroupName -Location $Location
        Write-Host "Created Web Server VM: $Vmname" -ForegroundColor Green
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