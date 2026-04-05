. "$PSScriptRoot\BlobHelper.ps1"
. "$PSScriptRoot\AzCopyHelper.ps1"

$ResourceGroupName = "az104StorageAccount-rg"
$Location = "East US"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$uniqueString = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

$storageAccountObj = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
                    -Name "storageaccount$uniqueString" `
                    -Location $Location `
                    -SkuName "Standard_LRS" `
                    -Kind "StorageV2" `
                    -AccessTier "Hot" `
                    -MinimumTlsVersion "TLS1_2" `
                    -EnableHttpsTrafficOnly $true `
                    -AllowBlobPublicAccess $true

$storageAccountObj | Select-Object -Property StorageAccountName, Kind, MinimumTlsVersion, EnableHttpsTrafficOnly
                    
Write-Host "Storage Account obj type:  $($storageAccountObj.GetType().FullName)"
# Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount

New-AzBlobContainerCreation -StrAccObj $storageAccountObj -ResourceGroupName $ResourceGroupName


$storageAccountContext = $storageAccountObj.Context

Write-Host "Storage Account CONTEXT type:  $($storageAccountContext.GetType().FullName)"
#Microsoft.WindowsAzure.Commands.Common.Storage.LazyAzureStorageContext

# Clean up resources
Remove-AzResourceGroup -ResourceGroupName $ResourceGroupName