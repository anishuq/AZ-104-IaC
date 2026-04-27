<#
We are going to mix AZ CLI and PowerShell in this script, 
so we need to set the execution policy to allow running scripts.

We will do the basic connection to Azure with PS and then we will 
create a new resource group and a new virtual machine with AZ CLI.
#>

$context = Get-AzContext

if ($context) {
    Write-Host "Yes, Logged in as: $($context.Account.Id)"
    Write-Host "Subscription: $($context.Subscription.Name)"
} else {
    Write-Host "No, Not logged in. Running Connect-AzAccount..."
    Connect-AzAccount
    $SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
    Select-AzSubscription -SubscriptionId $SubscriptionId
}
$ResourceGroupName = "AzCliInfrastructure-RG"
$Location = "EastUS"
$linuxImage = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"

az group create --name $ResourceGroupName --location $Location

#this is a sample VM creation with AZ CLI, you can customize the parameters as needed.
az vm create --resource-group $ResourceGroupName `
             --name "azclivmlinux01" `
             --image $linuxImage `
             --admin-username "adm.anisulhuq" `
             --admin-password "McIe@4:5WmFvM" `
             --size "Standard_B2s" `
             --public-ip-address "azclivmlinux01pip" `
             --nsg-rule SSH

$winImage = "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"

az vm create --resource-group $ResourceGroupName `
             --name "azclivmwin01" `
             --image $winImage `
             --admin-username "admanisulhuq" `
             --admin-password "McIe4@5WmFvMwiN" `
             --size "Standard_B2s" `
             --public-ip-address "azclivmwin01pip" `
             --nsg-rule RDP