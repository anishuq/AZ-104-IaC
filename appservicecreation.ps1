$ResourceGroupName = "az104appservice-rg"
$Location = "Canada Central"
$AppServicePlanName = "az104appservice-plan"
$AppServiceInstance = "myfirstwebapp160980"

$subscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"

Connect-AzAccount

Select-AzSubscription -SubscriptionId $subscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

New-AzAppServicePlan -Name $AppServicePlanName -Location $Location `
-ResourceGroupName $ResourceGroupName -Tier "Standard" `
-NumberofWorkers 1 `
-Linux `
-WorkerSize "Small"

New-AzWebApp -ResourceGroupName $ResourceGroupName `
-Name $AppServiceInstance `
-Location $Location `
-AppServicePlan $AppServicePlanName 


Write-Host "Web App deployed successfully! We are also in github now"
Write-Host "commit 2"
Write-Host "commit 3"