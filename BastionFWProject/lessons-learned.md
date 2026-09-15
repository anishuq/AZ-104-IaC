
# Lessons Learned — Bastion + Firewall Project

## 1. Parameter scope bug in `BastionHelper.ps1`

`New-AzBastionCreation` declares a `-Location` parameter but never actually uses it inside the function. Instead, the Public IP creation line references `$Location1`:

```powershell
$BastionPip = New-AzPublicIPCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    ...
```

This only worked because `$Location1` happens to exist as a variable in the calling script's scope (`main.ps1`), and PowerShell functions can read variables from the parent scope when a name isn't shadowed locally. It's fragile: if this function were ever called from a different script, or if `$Location1` weren't defined by that name, it would silently fail or throw an undefined-variable error, and the `-Location` parameter being passed in would be quietly ignored the whole time.

**Takeaway:** always use the parameter you declared (`$Location`, not `$Location1`) inside a function body. Relying on scope leakage from the caller works by accident, not by design, and it's the kind of thing that passes testing once and breaks the next time the script gets reused.

## 2. Fragile subnet ordering in `FWHelper.ps1`

The route table attachment step uses:

```powershell
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetObj -Name $vnetObj.Subnets[0].Name ...
```

This assumes `WorkLoad_subnet` is always index `[0]` in the subnet array, which is currently true only because it's listed first in `New-AzVNetSubnetsCreation`. If the subnet list order ever changed (say, Bastion got listed first), this line would silently attach the forced-tunneling route to the wrong subnet, no error, just wrong behavior that would be hard to spot without checking the portal.

**Takeaway:** referencing subnets by array index instead of by name is a real risk in IaC. Safer pattern: `($vnetObj.Subnets | Where-Object Name -eq $SubnetName1)` or just pass the subnet name explicitly instead of trusting position.

## 3. Reused hardcoded plaintext password

Same issue as the ApplicationSecurityGroupProject script: `$plainPassword = "McIe@4-5WmFvM"` is hardcoded here too, and it's the exact same password. That's a second thing worth fixing beyond just this file: a repo-wide password rotation and a shared credential-handling pattern (Key Vault reference or `Get-Credential` prompt) used consistently across every project script, so this doesn't get copy-pasted into the next one too.

## 4. Textbook vs. actual build

The book exercise this was based on used a Windows VM (RDP via Bastion). The actual script deploys Ubuntu 22.04, so Bastion here is doing SSH, not RDP. Worth remembering when reviewing this project later, the concepts (Bastion tunneling, no public IP on the VM) are identical either way, but the connection method in the portal will look different from what a textbook screenshot shows.

## What to double check before reusing this script

- Confirm `AzureBastionSubnet` sizing requirements for the Bastion SKU being used. Minimum subnet size requirements have changed across Bastion SKU tiers (Basic vs Standard vs Developer), worth checking current Microsoft Learn docs rather than assuming `/27` is always valid.
- Verify the firewall's default deny behavior interacts the way expected with the network rule for DNS, test an actual outbound query from the VM once deployed, don't just trust the rule collection was created correctly.
