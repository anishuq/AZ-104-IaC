. "$PSScriptRoot\NetworkHelper.ps1"


$ResourceGroupName = "loadbalancer-rg"

$ret = New-AzVNetSubnetCreation -vnetName "myVNet" -subnetName "mySubnet" -addressPrefix "10.0.1.0/24"

Write-Host "Returned value from New-AzVNetSubnetCreation: $($ret)"