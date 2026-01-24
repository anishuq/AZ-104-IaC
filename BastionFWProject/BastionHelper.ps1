
. "$PSScriptRoot\PipHelper.ps1"

function New-AzBastionCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$BastionName,
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$VNetObj
    )

    #create the Public IP for Bastion
    $BastionPip = New-AzPublicIPCreation -ResourceGroupName $ResourceGroupName `
        -Location $Location1 `
        -PipName "BastionPip" `
        -Sku "Standard" `
        -AllocationMethod "Static"
    
    $BastionParameters = @{
        Name              = $BastionName
        ResourceGroupName = $ResourceGroupName
        #Location is NOT needed here as it is referred from the VNet
        VirtualNetwork    = $VNetObj
        PublicIpAddress   = $BastionPip
    }

    #Create the Bastion
    $bastionObj = New-AzBastion @BastionParameters
}