<#
THIS CODE IS ENTIRELY CLAUDE GENERATED.
#>


Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId


$resourceGroup = "AzFileSync-rg"
$syncService   = "AzureFileSyncServiceLab"
$syncGroup     = "azurefilesyncgrouplab"

# Check what's still in the sync group
Write-Host "=== Checking remaining endpoints ===" -ForegroundColor Cyan
Get-AzStorageSyncServerEndpoint `
    -ResourceGroupName $resourceGroup `
    -StorageSyncServiceName $syncService `
    -SyncGroupName $syncGroup `
    -ErrorAction SilentlyContinue

Get-AzStorageSyncCloudEndpoint `
    -ResourceGroupName $resourceGroup `
    -StorageSyncServiceName $syncService `
    -SyncGroupName $syncGroup `
    -ErrorAction SilentlyContinue

# Remove Cloud Endpoint
Write-Host "`n=== Removing Cloud Endpoint ===" -ForegroundColor Cyan
$ce = Get-AzStorageSyncCloudEndpoint `
    -ResourceGroupName $resourceGroup `
    -StorageSyncServiceName $syncService `
    -SyncGroupName $syncGroup

if ($ce) {
    Remove-AzStorageSyncCloudEndpoint `
        -ResourceGroupName $resourceGroup `
        -StorageSyncServiceName $syncService `
        -SyncGroupName $syncGroup `
        -Name $ce.CloudEndpointName `
        -Force
    Write-Host "Cloud endpoint removed." -ForegroundColor Green
} else {
    Write-Host "No cloud endpoints found." -ForegroundColor Green
}

# Remove Sync Group
Write-Host "`n=== Removing Sync Group ===" -ForegroundColor Cyan
Remove-AzStorageSyncGroup `
    -ResourceGroupName $resourceGroup `
    -StorageSyncServiceName $syncService `
    -Name $syncGroup `
    -Force
Write-Host "Sync group removed." -ForegroundColor Green

# Delete Storage Sync Service
Write-Host "`n=== Deleting Storage Sync Service ===" -ForegroundColor Cyan
Remove-AzStorageSyncService `
    -ResourceGroupName $resourceGroup `
    -Name $syncService `
    -Force

Write-Host "`n✅ Storage Sync Service deleted!" -ForegroundColor Green