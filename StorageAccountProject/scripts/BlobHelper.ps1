"$PSScriptRoot\AzCopyHelper.ps1"

function New-AzBlobContainerCreation {
    param(
        [Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount]$StrAccObj,
        [string]$ResourceGroupName
    )

    #We must get the access keys to get "root" access
    $keys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name  $StrAccObj.StorageAccountName
    $key1 = $keys[0].Value  


     #Get the storage account context using key1

    <# Rotate Key2. Just to learn how to rotate keys. We will use key1 to do the work, 
    and then rotate key2 to invalidate any access that might be using key2 #>

    New-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
                 -Name  $StrAccObj.StorageAccountName -KeyName "key2"

    #Get the storage account context using key1
    $storageAccountContext = New-AzStorageContext -StorageAccountName `
                                $StrAccObj.StorageAccountName -StorageAccountKey $key1

    #Create a blob container named "privateblobcontainer" in the storage account using the context we just created
    $blobContainerObj1 = New-AzStorageContainer -Name "privateblobcontainer" -Context $storageAccountContext `
                                        -PublicAccess Off 
     Write-Host "Blob Container with NO public access Object type:  $($blobContainerObj3.GetType().FullName)"

    $blobContainerObj2 = New-AzStorageContainer -Name "azcopysource" -Context $storageAccountContext `
                                        -PublicAccess Container 

    $blobContainerObj3 = New-AzStorageContainer -Name "azcopydestination" -Context $storageAccountContext `
                                        -PublicAccess Container 
    Write-Host "Blob Container Object type:  $($blobContainerObj3.GetType().FullName)"

    Get-AzStorageContainer -Context $storageAccountContext 

    #Now we upload to the public blob container using the context with key1, and then we will try to access it anonymously
    $filePath = "$PSScriptRoot\samplefile.txt"
    Set-AzStorageBlobContent -File $filePath -Container $blobContainerObj2.Name `
                                                 -Context $storageAccountContext

    #In this function we will generate account SAS key and use that for copying 

}
