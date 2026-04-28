. "$PSScriptRoot\cleanup.ps1"

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
$winVMName = "azclivmwin01"


az vm create --resource-group $ResourceGroupName `
             --name $winVMName `
             --image $winImage `
             --admin-username "admanisulhuq" `
             --admin-password "McIe4@5WmFvMwiN" `
             --size "Standard_B2s" `
             --public-ip-address "azclivmwin01pip" `
             --nsg-rule RDP

<# From this point on we will only work with the Windows VM#>
Write-Host "We have to WAIT until $winVMName has been CREATED ...."
az vm wait --resource-group $ResourceGroupName --name $winVMName --created


# Give the guest agent time to initialize
Start-Sleep -Seconds 60


Write-Host "Checking the VM Extension status of $winVMName"
az vm get-instance-view --resource-group $ResourceGroupName `
                        --name $winVMName `
                        --query "instanceView.vmAgent.statuses[0].message" -o tsv

#install network watcher agent
az vm extension set `
  --resource-group $ResourceGroupName `
  --vm-name $winVMName `
  --name "NetworkWatcherAgentWindows" `
  --publisher "Microsoft.Azure.NetworkWatcher" `
  --no-auto-upgrade-minor-version

Remove-AzResourceGroup -ResourceGroupName $ResourceGroupName