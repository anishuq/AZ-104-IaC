. "$PSScriptRoot/VMInstanceHelper.ps1"


$ResourceGroupName = "AZ104-RecoveryServiceVault-RG"

$Location = "canadacentral"


#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in canadacentral.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$vmObj = New-AzVMInstance -ResourceGroupName $ResourceGroupName -Location $Location

$vaultObj = New-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name "AZ104RecoveryServiceVault"

Set-AzRecoveryServicesBackupProperty -Vault $vaultObj -BackupStorageRedundancy GeoRedundant

