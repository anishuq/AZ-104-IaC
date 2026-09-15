
# Bastion + Azure Firewall Project

A PowerShell IaC lab that builds a hub-style network where a VM has **no public IP at all**. Management access comes in through Azure Bastion, and all outbound internet traffic is forced through Azure Firewall.

## What gets deployed

- 1 resource group, 1 VNet (`10.0.0.0/16`) in East US 2, with three subnets:
  - `WorkLoad_subnet` (10.0.0.0/24) — holds the VM
  - `AzureBastionSubnet` (10.0.1.0/27) — reserved name, required exactly as-is
  - `AzureFirewallSubnet` (10.0.2.0/26) — reserved name, required exactly as-is
- 1 VM (`workloadvm`, Ubuntu 22.04) in the workload subnet, **no public IP**
- 1 Azure Bastion host (`MyBastionHost`), with its own public IP, for browser-based SSH into the VM
- 1 Azure Firewall (`EgressFW`), with its own public IP
- 1 route table (`RTEgress`) forcing all outbound traffic (`0.0.0.0/0`) from the workload subnet through the firewall's private IP
- Firewall rules: an application rule allowing HTTP/HTTPS to `www.google.com`, and a network rule allowing UDP 53 (DNS) to `8.8.8.8`
- The VM's NIC DNS is manually set to `8.8.8.8`

## What this demonstrates for AZ-104

**Reserved subnet names.** `AzureBastionSubnet` and `AzureFirewallSubnet` are not arbitrary labels, Azure requires those exact names for Bastion and Firewall to deploy into them. This is a well-known exam trap: if a question describes Bastion or Firewall deployment failing, check whether the subnet was actually named correctly before looking anywhere else.

**Bastion removes the need for a public IP on the VM.** The VM in this lab has zero public exposure. Bastion sits in its own subnet with its own public IP and proxies the SSH/RDP session through the Azure portal over TLS. This is the direct alternative to the old pattern of opening port 22/3389 to the internet on the VM itself.

**Forced tunneling via UDR.** The route table's single route, `0.0.0.0/0 → VirtualAppliance → firewall's private IP`, is what makes Azure Firewall actually enforce anything. Without this route, traffic from the VM would just go straight to the internet, bypassing the firewall entirely. The route table is deliberately associated only with `WorkLoad_subnet`, not the Bastion or Firewall subnets, associating it everywhere would create a routing loop (firewall traffic trying to route through itself).

**Firewall rule types are different filtering layers, not the same thing.** The application rule collection filters by FQDN (`www.google.com`) at the HTTP/HTTPS layer. The network rule collection filters by IP/port/protocol (UDP 53 to `8.8.8.8`). DNS resolution needs the network rule, not the application rule, because DNS isn't HTTP traffic. This split (app rules vs. network rules, each with their own priority and rule collection) is core exam material for Azure Firewall.

**Why DNS needed two separate pieces.** Setting the VM's NIC to use `8.8.8.8` only tells the VM where to send DNS queries. It says nothing about whether that traffic is allowed to leave the subnet. The firewall's default behavior is deny-all, so the network rule permitting UDP 53 outbound to `8.8.8.8` is what actually lets those DNS queries reach their destination. Both pieces were required together.

## Known issue

`main.ps1` has a hardcoded plaintext VM password, same one reused from the ApplicationSecurityGroupProject script. See the lessons-learned doc for details, this needs fixing repo-wide, not just here.
