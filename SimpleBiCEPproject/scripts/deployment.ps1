$ResourceGroupName = "simple-bicep-rg"

# Define Location
$Location = "canadacentral"

#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

az deployment group create --resource-group $ResourceGroupName --template-file .\main.bicep --parameters .\dev.bicepparam

Write-Host "Deployment completed successfully and the resource group $ResourceGroupName has been created."
Write-Host "In order to delete the resource group and all its resources, press Y/y"
az group delete --resource-group $ResourceGroupName

