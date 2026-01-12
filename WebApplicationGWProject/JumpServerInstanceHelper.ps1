Write-Host "VM Instance Helper Loaded!"

<#
.SYNOPSIS
    Creates a Jumpbox VM.
.DESCRIPTION
    Creates a PIP first and then creates the Jumpbox VM for admin purposes 
.NOTES
    We have opened both SSH port and xRDP ports.
.LINK
    No URI.
.EXAMPLE
#>
function New-AzVMCreation{
    param (
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
        ErrorAction       = "Stop"
    }

    $pipName = "jumpbox-pip"
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



