# Define Resource Group Name which is already created.
$ResourceGroupName = "az104-paas-linuxappservice-rg"

# Define Location
$Location = "canadacentral"
$AppServicePlanName = "az104-linuxappserviceplan"
$WebAppName = "az104-linuxwebapp-$(Get-Random)"
#Get-Random Returns a non-negative random integer between 0 and [Int32]::MaxValue (2,147,483,647).

#Create Connection to Azure Account
Connect-AzAccount -Tenant (Get-AzContext).Tenant.Id -ClaimsChallenge "eyJhY2Nlc3NfdG9rZW4iOnsiYWNycyI6eyJlc3NlbnRpYWwiOnRydWUsInZhbHVlcyI6WyJwMSJdfX19"
<#
Detailed explanation in "Miscellaneous PowerShell topics"
#>
$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

#Create App Service Plan
New-AzAppServicePlan -Name $AppServicePlanName -ResourceGroupName $ResourceGroupName `
-Location $Location -Tier "Standard" -WorkerSize "Small" -NumberofWorkers 1 -Linux

#Create an web app in the App Service Plan
New-AzWebApp -Name $WebAppName -ResourceGroupName $ResourceGroupName `
-Location $Location -AppServicePlan $AppServicePlanName 
