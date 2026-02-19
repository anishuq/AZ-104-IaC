
Write-Host "VM Helper Loaded!"

function New-AzVMInstanceCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$VMName,
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$VnetObj,
        [string]$Image,
        [string]$NicName,
        [Microsoft.Azure.Commands.Network.Models.PSPublicIpAddress]$PublicIpAddress,
        [System.Management.Automation.PSCredential] $Credential
    )

    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    } 

    #Create a NIC that is a is the bridge between your VM and the virtual network. 
    #In PowerShell, we use the New-AzNetworkInterface command, referencing the vpnvnet and vnpsubnet.
    Write-Host "Creating NIC: $NicName ..... "
    $nicObj = New-AzNetworkInterface -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -Name $NicName `
        -SubnetId $vnetObj.Subnets[0].Id `
        -PublicIpAddressId $PublicIpAddress.Id `
        -ErrorAction Stop
    
        Write-Host "NIC obj type:  $($nicObj.GetType().FullName)" 

    #Define the VM configuration
    # 1. Start the config
    $vmConfigObj = New-AzVMConfig -VMName $VMName -VMSize "Standard_D2s_v4"

    # 2. Attach the NIC ID (The glue)
    $vmConfigObj = Add-AzVMNetworkInterface -VM $vmConfigObj -Id $nicObj.Id

    
    
    # 3. Set the OS Image
    #$Image = "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"
    # Since you defined $Image earlier as a string, we split it here
    $imageParts = $Image.Split(":")

    $vmConfigObj = Set-AzVMSourceImage -VM $vmConfigObj `
        -PublisherName $imageParts[0] `
        -Offer $imageParts[1] `
        -Skus $imageParts[2] `
        -Version $imageParts[3]

    # 4. Set Operating System (THIS WAS MISSING!)
    $vmConfigObj = Set-AzVMOperatingSystem -VM $vmConfigObj `
        -Windows `
        -ComputerName $VMName `
        -Credential $Credential `
        -ProvisionVMAgent `
        -EnableAutoUpdate    

    # 4. Set OS Disk and Credentials
    $vmConfigObj = Set-AzVMOSDisk -VM $vmConfigObj -CreateOption FromImage -DiskSizeInGB 128
    $vmConfigObj = Set-AzVMBootDiagnostic -VM $vmConfigObj -Enable

    Write-Host "Finally we are going to CREATE the VM now"
    $vmObj = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfigObj

    Write-Host "VM obj type:  $($vmObj.GetType().FullName)"

    Write-Host "We want to be here with NO Error!"

    return $vmObj
    
}