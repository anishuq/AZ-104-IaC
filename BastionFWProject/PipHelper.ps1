Write-Host "Pip Helper Loaded!"

function New-AzPublicIPCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$PipName,
        [string]$Sku,
        [string]$AllocationMethod
    )

    $PipParameters = @{
        Name              = $PipName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        Sku               = $Sku
        AllocationMethod  = $AllocationMethod
    }

    #Create the Public IP
    $pip = New-AzPublicIpAddress @PipParameters

    Write-Host "Public IP obj type:  $($pip.GetType().FullName)"
    return $pip
}