. "$PSScriptRoot\AzCopyAccSASHelper.ps1"
. "$PSScriptRoot\AzCopyServiceSASHelper.ps1"

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

    #Create the storage account context using key1 using New-AzStorageContext
    $storageAccountContext = New-AzStorageContext -StorageAccountName `
                                $StrAccObj.StorageAccountName -StorageAccountKey $key1

    Write-Host "Storage Account CONTEXT type in BLOBHELPER when New-AzStorageContext:  $($storageAccountContext.GetType().FullName)"

    #Create a blob container named "privateblobcontainer" in the storage account using the context we just created
    $blobContainerObj1 = New-AzStorageContainer -Name "privateblobcontainer" -Context $storageAccountContext `
                                        -PublicAccess Off 
    Write-Host "Blob Container with NO public access Object type:  $($blobContainerObj1.GetType().FullName)"

    $blobContainerObj2 = New-AzStorageContainer -Name "azcopysource" -Context $storageAccountContext `
                                        -PublicAccess Container 

    $blobContainerObj3 = New-AzStorageContainer -Name "azcopydestination" -Context $storageAccountContext `
                                        -PublicAccess Container 
    
    Write-Host "We are here!"
    Write-Host "Blob Container Object type:  $($blobContainerObj3.GetType().FullName)"

    Get-AzStorageContainer -Context $storageAccountContext | Out-Null

    #Now we upload to the public blob container using the context with key1, and then we will try to access it anonymously
    $filePath = "$PSScriptRoot\samplefile.txt"
    Set-AzStorageBlobContent -File $filePath -Container $blobContainerObj2.Name `
                                                 -Context $storageAccountContext

    #In this function we will generate account SAS token and use that for copying 
    New-AzCopyAccSASOperations -StorageAccObj $StrAccObj -ctx $storageAccountContext `
    -azcopysourcecontainer $blobContainerObj2 -azcopydestinationcontainer $blobContainerObj3
 
    
    #In this function we will generate 2 SERVICE SAS tokens and use that for copying from
    #one CONTAINER to another. 
    New-AzCopyServiceSASOperations -StorageAccObj $StrAccObj -ctx $storageAccountContext `
    -azcopysourcecontainer $blobContainerObj2 -azcopydestinationcontainer $blobContainerObj3
}
