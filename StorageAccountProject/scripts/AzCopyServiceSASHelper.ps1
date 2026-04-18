function New-AzCopyServiceSASOperations {
    param (
        [Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount]$StorageAccObj,
        [Microsoft.WindowsAzure.Commands.Storage.Common.AzureStorageContext]$ctx,
        
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageContainer]$azcopysourcecontainer,
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageContainer]$azcopydestinationcontainer
    )

    #create 2 service SAS tokens for 24 hours   
    $startTime = (Get-Date).ToUniversalTime()
    $expiryTime = $startTime.AddHours(24)

    $sourceSASToken = New-AzStorageContainerSASToken -Name $azcopysourcecontainer.Name `
                                                    -Permission rl `
                                                    -StartTime $startTime `
                                                    -ExpiryTime $expiryTime `
                                                    -Context $ctx
     #the PERMISSION line is absolutely crucial

    $destinationSASToken = New-AzStorageContainerSASToken -Name $azcopydestinationcontainer.Name `
                                                    -Permission rwdlac `
                                                    -StartTime $startTime `
                                                    -ExpiryTime $expiryTime `
                                                    -Context $ctx
    #the PERMISSION line is absolutely crucial

    $sourceURL = "https://$($StorageAccObj.StorageAccountName).blob.core.windows.net/$($azcopysourcecontainer.Name)?$sourceSASToken"
    $destinationURL = "https://$($StorageAccObj.StorageAccountName).blob.core.windows.net/$($azcopydestinationcontainer.Name)?$destinationSASToken"

    Write-Host "------------ Service ACC copy --------------------"
    $azcopyPath = "C:\AzCopy\azcopy.exe"

    & $azcopyPath copy $sourceURL $destinationURL --recursive
}