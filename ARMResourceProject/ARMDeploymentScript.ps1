# Define Resource Group Name
$ResourceGroupName = "ARMTemplateInfrastructure-RG"
$Location = "eastus"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$result = Test-AzResourceGroupDeployment `
  -ResourceGroupName $ResourceGroupName `
  -TemplateFile ".\scripts\VMCreation.json" `
  -TemplateParameterFile ".\scripts\VMCreation.parameters.json" `
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
            -TemplateFile ".\scripts\VMCreation.json" `
            -TemplateParameterFile ".\scripts\VMCreation.parameters.json" `
            -Name "VMCreationDeployment" `
            -Verbose
} else {
    Write-Host "❌ Template is INVALID" -ForegroundColor Red
    $result.Details | Format-List *
}