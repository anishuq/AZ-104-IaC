Write-Host "Creating VM instance..."

<#
This is s simplified VM creation where the VM is only
created to test the backup and restore functionality of the Recovery Services Vault. 
#>
function New-AzVMInstance {
    param(
        [string]$ResourceGroupName,
        [string]$Location
    )

    $username = "admanisulhuq" #enter username for all VM
    $plainPassword = "McIe@4-5WmFvM" #enter password for VM
    $password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
    $vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)
    
    $vmParams = @{
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        Name              = "BCDRVM1"
        Image             = "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"
        Size              = "Standard_B2s"
        Credential        = $vmcred
        ErrorAction       = "Stop"
    }

    $vmObj = New-AzVM @vmParams    

    return $vmObj
}
