Write-Host "Storage Account Helper Loaded!"

function New-StorageAccountCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$VmName
    )

    #print all the params
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key]) and Type: $($PSBoundParameters[$key].GetType().Name)"
    } 

    <#Create an Unique Storage Account Name through hashing (MD5) the Resource Group Name and VM Name. 
    is is to avoid any naming conflicts as Storage Account names are globally unique.
    #>
    $BaseName = $VmName.ToLower()
    $MD5 = [System.Security.Cryptography.MD5]::Create()
    $HashBytes = $MD5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ResourceGroupName))
    $Hash = ([System.BitConverter]::ToString($HashBytes) -replace '-','').Substring(0,5).ToLower()
    $StorageAccountName = "$BaseName$Hash"
    <# Explaination for the ABOVE code is in "MiscellaneousPowerShelltopics" doc#>

    $strAccObj = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
                        -Name $StorageAccountName `
                        -Location $Location `
                        -SkuName Standard_LRS `
                        -Kind StorageV2

    return $strAccObj
}
