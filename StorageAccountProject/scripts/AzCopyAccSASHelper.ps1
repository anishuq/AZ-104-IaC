function New-AzCopyAccSASOperations {
    param (
        [Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount]$StorageAccObj,
        [Microsoft.WindowsAzure.Commands.Storage.Common.AzureStorageContext]$ctx,
        
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageContainer]$azcopysourcecontainer,
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageContainer]$azcopydestinationcontainer
    )

    #create an account SAS token for 24 hours   
    $startTime = (Get-Date).ToUniversalTime()
    $expiryTime = $startTime.AddHours(24)


    $accountSAS = New-AzStorageAccountSASToken `
                    -Service Blob, File, Queue, Table `
                    -ResourceType Service, Container, Object `
                    -Permission rwdlacuptfx `
                    -StartTime $startTime `
                    -ExpiryTime $expiryTime `
                    -Context $ctx

    $filePath = "C:\AzCopy\SampleFile2.txt"
    $azcopyPath = "C:\AzCopy\azcopy.exe"
    
    $destURL = "https://$($StorageAccObj.StorageAccountName).blob.core.windows.net/$($azcopydestinationcontainer.Name)?$accountSAS"

    Write-Host "dest URL used: $destURL"
    #With AZCOPY we are going to upload a FILE to a BLOB CONTAINER.
    if ((Test-Path $filePath) -and (Test-Path $azcopyPath)){
        Write-Host "Condition OK!"
        & $azcopyPath copy $filePath $destURL
    }else{

        Write-Host "Path Wrong!!!!"
    } 


}