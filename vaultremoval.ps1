<#
This is not my code!
#>

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

# ── Step 0: Point at the vault ──────────────────────────────────────────────
$vaultName = "AZ104-RecoverVault"
$rgName    = "AZ104-RecoverVault-RG"

$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $rgName

# ── Step 1: Disable Soft Delete ─────────────────────────────────────────────
Set-AzRecoveryServicesVaultProperty `
    -VaultId $vault.ID `
    -SoftDeleteFeatureState Disable
Write-Host "✓ Soft delete disabled" -ForegroundColor Green

# ── Step 2: Disable Enhanced Security (covers MARS/MAB/DPM agents) ──────────
Set-AzRecoveryServicesVaultProperty `
    -VaultId $vault.ID `
    -DisableHybridBackupSecurityFeature $true
Write-Host "✓ Hybrid security features disabled" -ForegroundColor Green

# ── Step 3: Remove all backup items (covers soft-deleted ones too) ───────────
$workloads = @(
    @{ Type = "AzureVM";      Mgmt = "AzureVM"      },
    @{ Type = "AzureFiles";   Mgmt = "AzureStorage"  },
    @{ Type = "MSSQL";        Mgmt = "AzureWorkload" },
    @{ Type = "SAPHanaDatabase"; Mgmt = "AzureWorkload" }
)

foreach ($w in $workloads) {
    $items = Get-AzRecoveryServicesBackupItem `
                 -BackupManagementType $w.Mgmt `
                 -WorkloadType $w.Type `
                 -VaultId $vault.ID `
                 -ErrorAction SilentlyContinue

    foreach ($item in $items) {
        # If soft-deleted, undelete first (only works for AzureVM)
        if ($item.DeleteState -eq "ToBeDeleted") {
            Undo-AzRecoveryServicesBackupItemDeletion `
                -Item $item -VaultId $vault.ID -Force
        }
        # Now disable protection and delete recovery points
        Disable-AzRecoveryServicesBackupProtection `
            -Item $item -VaultId $vault.ID `
            -RemoveRecoveryPoints -Force
        Write-Host "  ✓ Removed: $($item.Name)" -ForegroundColor Yellow
    }
}

# ── Step 4: Unregister backup containers ────────────────────────────────────
$containerTypes = @("AzureVM", "Windows", "AzureStorage", "AzureVMAppContainer")

foreach ($ct in $containerTypes) {
    $containers = Get-AzRecoveryServicesBackupContainer `
                      -ContainerType $ct `
                      -VaultId $vault.ID `
                      -ErrorAction SilentlyContinue
    foreach ($c in $containers) {
        Unregister-AzRecoveryServicesBackupContainer `
            -Container $c -Force -VaultId $vault.ID
        Write-Host "  ✓ Unregistered container: $($c.FriendlyName)" -ForegroundColor Yellow
    }
}

# ── Step 5: Delete the vault via REST (required — cmdlet alone often fails) ──
$subId     = (Get-AzContext).Subscription.Id
$token     = (Get-AzAccessToken).Token
$headers   = @{
    'Content-Type'  = 'application/json'
    'Authorization' = "Bearer $token"
}
$restUri = "https://management.azure.com/subscriptions/$subId" +
           "/resourcegroups/$rgName/providers/Microsoft.RecoveryServices" +
           "/vaults/${vaultName}?api-version=2021-06-01&operation=DeleteVaultUsingPS"

Invoke-RestMethod -Uri $restUri -Headers $headers -Method DELETE
Write-Host "✓ Vault deleted" -ForegroundColor Green

# ── Step 6: Now the RG will delete cleanly ───────────────────────────────────
Remove-AzResourceGroup -Name $rgName -Force
Write-Host "✓ Resource group deleted" -ForegroundColor Green