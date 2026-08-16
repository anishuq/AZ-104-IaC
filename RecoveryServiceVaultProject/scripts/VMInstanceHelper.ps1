Write-Host "Creating VM instance..."

<#
This is s simplified VM creation where the VM is only
created to test the backup and restore functionality of the Recovery Services Vault. 
#>
function New-AzVMInstance {
    $vmParams = @{
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        VmName            = "BCDRVM1"
        Image             = "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"
        Size              = "Standard_B1s"
        AdminUsername     = "admanisulhuq"
        AdminPassword     = ConvertTo-SecureString "McIe@4:5WmFvM" -AsPlainText -Force
    }

    $vmObj = New-AzVM @vmParams    

    return $vmObj
}
