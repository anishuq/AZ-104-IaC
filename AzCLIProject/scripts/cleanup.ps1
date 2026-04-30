function Invoke-Cleanup {
    param (
        [string]$ResourceGroupName
    )
    
    $cleanup = Read-Host "Do you want to clean up the resources created? (Y/N)"
    if (($cleanup -eq "Y") -or ($cleanup -eq "y")) {
        Remove-AzResourceGroup -Name $ResourceGroupName -Force
        Write-Host "Resources cleaned up successfully."
    } else {
        Write-Host "Resources retained. Remember to clean up later to avoid unnecessary costs."
    }    
}
