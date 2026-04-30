. "$PSScriptRoot\BlobHelper.ps1"
. "$PSScriptRoot\AzCopyAccSASHelper.ps1"
. "$PSScriptRoot\AzCopyServiceSASHelper.ps1"
. "$PSScriptRoot\FileStorageHelper.ps1"

$ResourceGroupName = "az104StorageAccount-rg"
$Location = "East US"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$uniqueString = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()


$accessTier = Read-Host "Enter access tier for the storage account (Hot/Cool/Archive)"
$accessTier = $accessTier.Trim().ToLower()

# Validate against allowed values
$validTiers = @("hot", "cool", "archive")

if ($accessTier -notin $validTiers) {
    Write-Warning "Invalid input: '$accessTier'. Setting access tier to 'Hot' by default."
    $accessTier = "hot"
}

$type = Read-Host "Do you want Azure Azure File Storage only? (Y/N)"
if (($type -eq "Y") -or ($type -eq "y")) {
        New-AzFileStorageCreation -ResourceGroupName $ResourceGroupName -Location $Location -uniqueString $uniqueString -accessTier $accessTier
        Write-Host "Azure File Storage created and now we cleanup and exit."
    }
else{

        $storageAccountObj = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
                            -Name "storageaccount$uniqueString" `
                            -Location $Location `
                            -SkuName "Standard_LRS" `
                            -Kind "StorageV2" `
                            -AccessTier $accessTier `
                            -MinimumTlsVersion "TLS1_2" `
                            -EnableHttpsTrafficOnly $true `
                            -AllowBlobPublicAccess $true

        $storageAccountObj | Select-Object -Property StorageAccountName, Kind, MinimumTlsVersion, EnableHttpsTrafficOnly
        
        Write-Host "Storage Account obj type:  $($storageAccountObj.GetType().FullName)"
        # Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount

        New-AzBlobContainerCreation -StrAccObj $storageAccountObj -ResourceGroupName $ResourceGroupName


        $storageAccountContext = $storageAccountObj.Context
        Write-Host "Storage Account CONTEXT type in MAIN when storageAccountObj.Context :  $($storageAccountContext.GetType().FullName)"
        #Microsoft.WindowsAzure.Commands.Common.Storage.LazyAzureStorageContext
}
# Clean up resources
Invoke-Cleanup -ResourceGroupName $ResourceGroupName