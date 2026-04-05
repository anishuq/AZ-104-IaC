

function New-AzBlobContainerCreation {
    param(
        [Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount]$StrAccObj,
        [string]$ResourceGroupName
    )

    #We must get the access keys to get "root" access
    $keys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name  $StrAccObj.StorageAccountName
    $masterKey1 = $keys[0].Value  

}
