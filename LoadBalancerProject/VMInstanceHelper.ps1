Write-Host "VM Instance Helper Loaded!"


function New-AzVMCreation{
    param(
        [string]$vmname,
        [string]$subnetName,
        [string]$addressPrefix
    )
    Write-Host "This is a placeholder for New-AzVMCreation function. $($vmname), $($subnetName), $($addressPrefix)    "
    return "Howdee do from VMInstanceHelper"
}