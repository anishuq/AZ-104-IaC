

function New-AzNSGCreation {
    param (
        [string]$NSGName,
        [string]$ResourceGroupName,
        [string]$Location,
        [Microsoft.Azure.Commands.Network.Models.PSSecurityRule] $webRuleObj,
        [Microsoft.Azure.Commands.Network.Models.PSSecurityRule] $dbRuleObj,
        [Microsoft.Azure.Commands.Network.Models.PSSecurityRule] $denyRuleObj
    )

    

    $nsgParameters = @{
        Name              = $NSGName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        SecurityRules     = $webRuleObj, $dbRuleObj, $denyRuleObj
    }

    $nsgObj = New-AzNetworkSecurityGroup @nsgParameters

    Write-Host "Created NSG: $NSGName" -ForegroundColor Green

    return $nsgObj
}