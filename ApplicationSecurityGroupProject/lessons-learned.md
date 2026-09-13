
## What this demonstrates for AZ-104

**Application Security Groups as logical grouping.** Instead of writing an NSG rule that says "allow traffic from 10.0.2.0/24," the rule says "allow traffic from logicASG." VMs get tagged with an ASG on their NIC, and NSG rules reference the ASG, not the IP. Add or remove a VM from a tier and the security rule doesn't need to change. This is the core exam-relevant contrast: **NSG = the firewall, ASG = the label used inside firewall rules to group VMs by role instead of by subnet or IP.**

**NSG rule priority and default-deny layering.** The three rules are numbered 100, 110, 120. Lower priority number wins first. The explicit deny rule at 120 exists because without it, Azure's default NSG rules would otherwise allow VNet-internal traffic through, since Azure's baseline `AllowVNetInBound` rule sits at priority 65000, below any custom rule but still permissive. Writing your own explicit deny is what actually locks the DB tier down to only the one allowed source.

**Why the public IP path avoids `-OpenPorts` on `New-AzVM`.** The script comment on this is worth pulling into your own notes verbatim, it explains a specific gotcha: using the simplified `-OpenPorts` parameter on `New-AzVM` auto-creates a second, NIC-level NSG, separate from the subnet-level NSG being built here. That would leave two independent rule sets governing the same VM, which defeats the point of centralizing rules in one NSG driven by ASGs.

**IaC structure.** Splitting network, compute, ASG, and NSG logic into separate helper files and dot-sourcing them into `main.ps1` is a pattern worth carrying into every future project in this repo, it makes each Azure concept independently testable and reusable.

## Open item to verify

`main.ps1` creates `dbNSG` but I don't see it actually being associated with a subnet or a NIC anywhere in the script. An NSG that exists but isn't attached enforces nothing. Worth checking in the portal whether this got attached manually, or whether that association step is still missing from the script.

## Known issue

The current `main.ps1` has a hardcoded plaintext VM admin password. This needs to move to `Get-Credential`, a SecureString prompt, or Azure Key Vault before this script is reused, and the exposed credential should be rotated.
