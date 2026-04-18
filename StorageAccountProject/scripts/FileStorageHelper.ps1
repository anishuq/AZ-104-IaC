

function New-AzFileStorageCreation {
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$uniqueString
    )

    $storageAccountObj = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
                    -Name "storageaccount$uniqueString" `
                    -Location $Location `
                    -SkuName "Standard_LRS" `
                    -Kind "StorageV2" `
                    -AccessTier "Hot" `
                    -MinimumTlsVersion "TLS1_2" `
                    -EnableHttpsTrafficOnly $true `
                    -AllowBlobPublicAccess $false 
                    # In a "File Share only" scenario, there is no reason to allow anonymous public access to the blob service endpoint.

    # 2. Create the actual File Share inside the account
    New-AzStorageShare -Name "storageaccount$uniqueString-fileshare" -Context $storageAccountObj.Context

}