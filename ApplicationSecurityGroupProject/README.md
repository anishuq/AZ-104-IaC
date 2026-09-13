
# Application Security Group (ASG) Project

A PowerShell IaC lab that builds a 3-tier network (web / logic / database) and uses **Application Security Groups** instead of IP addresses to control traffic between tiers with an NSG.

## What gets deployed

- 1 resource group, 1 VNet (`10.0.0.0/16`) with two subnets: `WebSubnet` and `LogicDBSubnet`
- 3 VMs (Ubuntu 22.04): `webvm01` (public IP), `logicvm01` and `dbvm01` (no public IP)
- 3 ASGs: `webASG`, `logicASG`, `dbASG`, one per VM, used to tag each VM's NIC
- 1 NSG (`dbNSG`) with three rules, built entirely against ASGs rather than IP ranges:
  - Allow inbound internet traffic to `webASG` on port 80
  - Allow `logicASG` to reach `dbASG` on port 1433 (SQL)
  - Deny everything else headed to `dbASG` on port 1433

Scripts are split into focused helper functions (`NetworkHelper`, `VMInstanceHelper`, `ASGHelper`, `NSGHelper`), dot-sourced and run from `main.ps1`.
