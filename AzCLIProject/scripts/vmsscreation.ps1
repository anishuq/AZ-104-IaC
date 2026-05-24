. "$PSScriptRoot\cleanup.ps1"
$settingsPath = "$PSScriptRoot\settings.json"


<#
We are going to mix AZ CLI and PowerShell in this script, 
so we need to set the execution policy to allow running scripts.

We will do the basic connection to Azure with PS and then we will 
shift to AZ CLI.
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
$ResourceGroupName = "AzCliVMSSInfrastructure-RG"

# We will create the resources in CanadaCentral, choosing EASTUS won't have any quota.
$Location = "CanadaCentral"

az group create --name $ResourceGroupName --location $Location

$vmssName = "azclivmss01"
$winImage = "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"

az vmss create --resource-group $ResourceGroupName `
             --name $vmssName `
             --location $Location `
             --orchestration-mode flexible `
             --security-type "Standard" `
             --image $winImage `
             --vm-sku "Standard_B2ms" `
             --instance-count 2 `
             --admin-username "admanisulhuq" `
             --admin-password "McIe4@5WmFvMwiN" `
             --license-type "None" 

# All the VMs in the scale are NOT accessible via RDP by default, we need to add an extension to enable that.
Write-Host "VMSS created and the VMSS has created $($vmssName)NSG by default"
az network nsg rule create `
             --resource-group $ResourceGroupName `
             --nsg-name "$($vmssName)NSG" `
             --name "RDP" `
             --priority 1001 `
             --destination-port-ranges 3389 `
             --access Allow `
             --protocol Tcp


#We will use the Custom Script Extension to run a script on the VMSS instances that will install IIS and create a simple HTML page.
az vmss extension set `
             --resource-group $ResourceGroupName `
             --vmss-name $vmssName `
             --name "CustomScriptExtension" `
             --publisher "Microsoft.Compute" `
             --version "1.10" `
            --settings "@$settingsPath"


# 1. Ensure the provider is registered (only needs to be done once per subscription)
az provider register --namespace Microsoft.Insights

#First create the autoscale setting, then add a scale-out and scale-in rule:
$vmssId = (az vmss show --resource-group $ResourceGroupName --name $vmssName --query "id" -o tsv)
$scalingSettingsName = "vmsscalesettings01"
az monitor autoscale create `
                 --resource-group $ResourceGroupName `
                 --name $scalingSettingsName `
                 --resource $vmssId `
                 --location $Location `
                 --min-count 2 `
                 --max-count 5 `
                 --count 2

# Scale out: CPU > 70% for 5 min → add 1 instance
az monitor autoscale rule create `
    --resource-group $ResourceGroupName `
    --autoscale-name $scalingSettingsName `
    --condition "Percentage CPU > 70 avg 5m" `
    --scale out 1

# Scale in: CPU < 30% for 5 min → remove 1 instance
az monitor autoscale rule create `
    --resource-group $ResourceGroupName `
    --autoscale-name $scalingSettingsName `
    --condition "Percentage CPU < 30 avg 5m" `
    --scale in 1


Invoke-Cleanup -ResourceGroupName $ResourceGroupName