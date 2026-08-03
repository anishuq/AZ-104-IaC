

function New-AzPaaSStorageAccount{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$uniqueString
    )
    Write-Host "Creating PaaS Storage Account: $($ResourceGroupName), $($Location), $($uniqueString)"
    
    $storageAccountObj = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
                            -Name "storageaccount$uniqueString" `
                            -Location $Location `
                            -SkuName "Standard_LRS" `
                            -Kind "StorageV2" `
                            -AccessTier "Hot" `
                            -MinimumTlsVersion "TLS1_2" `
                            -EnableHttpsTrafficOnly $true `
                            -AllowBlobPublicAccess $true

    #$storageAccountObj | Select-Object -Property StorageAccountName, Kind, MinimumTlsVersion, EnableHttpsTrafficOnly
        
    Write-Host "Storage Account obj type:  $($storageAccountObj.GetType().FullName)"
    # Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount

    New-AzBlobContainerCreation -StrAccObj $storageAccountObj -ResourceGroupName $ResourceGroupName 