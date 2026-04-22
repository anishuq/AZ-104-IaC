# Define Resource Group Name
$ResourceGroupName = "ARMTemplateInfrastructure-RG"
$Location = "eastus"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$templateRoot = Read-Host "Enter the name of the ARM template file without the extension (e.g. VMCreation) "

if (Test-Path -Path ".\scripts\$templateRoot.json") {
    Write-Host "template file '$templateRoot' exists. Executing .... " -ForegroundColor Green
}
else {
    Write-Host "template file '$templateRoot' does not exist. Aborting." -ForegroundColor Red
    exit
}


$result = Test-AzResourceGroupDeployment `
  -ResourceGroupName $ResourceGroupName `
  -TemplateFile ".\scripts\$templateRoot.json" `
  -TemplateParameterFile ".\scripts\$templateRoot.parameters.json" `
  -Verbose

<# Step 2 - drill into each level
$result | Format-List *
$result.Details | Format-List *
$result.Details.Details | Format-List *
#>

# null = no errors = valid ✅
if ($null -eq $result) {
    Write-Host "✅ Template is VALID - ready to deploy" -ForegroundColor Green

    New-AzResourceGroupDeployment `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile ".\scripts\$templateRoot.json" `
            -TemplateParameterFile ".\scripts\$templateRoot.parameters.json" `
            -Name "$templateRoot-Deployment" `
            -Verbose
} else {
    Write-Host "❌ Template is INVALID" -ForegroundColor Red
    $result.Details | Format-List *
}