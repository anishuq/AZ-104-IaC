

function New-AzVMCreation{ 
    param (
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$VNetName,
        [string]$SubnetName,
        [string]$Vmname,
        [System.Management.Automation.PSCredential]$vmcred,
        [string]$pipName,
        [string]$Image
    )

    $pip = New-AzPublicIpAddress -Name $pipName `
         -ResourceGroupName $ResourceGroupName `
         -Location $Location `
         -AllocationMethod Static `
         -Sku Standard



New-AzVM -ResourceGroupName $ResourceGroupName `
         -Name $Vmname `
         -Location $Location `
         -Size "Standard_B1s" `
         -VirtualNetworkName $VNetName `
         -SubnetName $SubnetName `
         -PublicIpAddressName $pip.Name `
         -OpenPorts 22 `
         -Image $Image `
         -Credential $vmcred
}