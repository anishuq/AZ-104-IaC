[README.md](https://github.com/user-attachments/files/32165086/README.md)
# AZ-104-IaC

Hands-on Infrastructure-as-Code labs built while studying for the **Microsoft AZ-104: Azure Administrator** certification.

Every folder here is a real deployment in my own Azure subscription, built with PowerShell, Azure CLI, ARM templates, or Bicep. No portal-only clicking. If it's in this repo, it was scripted and it ran.

## Why this repo exists

Studying from a textbook only gets you so far. Most of the labs here started as textbook exercises that broke in practice (deployment errors, deprecated syntax, missing permissions), and the folder is what I built after fixing them myself. That's also why some folders have more than one attempt in them.

## Tech stack

PowerShell 7 · Azure CLI · ARM Templates · Bicep · GitHub Actions

## Repo structure by AZ-104 domain

### 1. Manage Azure identities and governance
| Folder | What it covers |
|---|---|
| `EntraIDUserManagementProject` | Entra ID user/group management |
| `ResourceTagsProject` | Resource tagging strategy |

### 2. Implement and manage storage
| Folder | What it covers |
|---|---|
| `StorageAccountProject` | Storage accounts, blob tiers, lifecycle policies |

### 3. Deploy and manage Azure compute resources
| Folder | What it covers |
|---|---|
| `AppServiceProject` | App Service deployment |
| `AppServiceCodeProject` | App Service with code deployment / CI-CD |
| `ContainerProject` | Azure Container Instances |
| `AzCLIProject` | Azure CLI-driven deployments |
| `vmcreation.ps1` | VM provisioning script |
| `appservicecreation.ps1` | App Service provisioning script |

### 4. Implement and manage virtual networking
| Folder | What it covers |
|---|---|
| `ApplicationSecurityGroupProject` | ASGs for VM-level network segmentation |
| `BastionFWProject` | Azure Bastion and Firewall |
| `LoadBalancerProject` / `LoadBalancerPortalProject` | Load Balancer via script and portal |
| `WebApplicationGWProject` | Application Gateway |
| `MockOnPremVPNSite` | Simulated on-prem site for VPN testing |
| `NetworkWatcherProject` / `NetworkWatcherVPNTroubleShoot` | Network Watcher: flow logs, connection monitor, VPN troubleshooting |
| `PrivateDNS` / `PublicDNSDemo` | DNS zone configuration |
| `PrivateEndPointProject` | Private Endpoints |
| `ServiceEndpoint` | Service Endpoints |
| `az104vnet01.ps1` | Base VNet setup |
| `vnetpeering-new.ps1` | VNet peering (hub-and-spoke) |
| `vpn-infra.ps1` / `vpngw-p2s.ps1` | VPN Gateway: site-to-site and point-to-site |
| `webappgw.sh` | App Gateway (CLI/bash variant) |

### 5. Monitor and maintain Azure resources
| Folder | What it covers |
|---|---|
| `AzureMonitorProject` | Azure Monitor, VM Insights, alerting |
| `RecoveryServiceVaultProject` | Backup and Recovery Services Vault |
| `vaultremoval.ps1` | Vault cleanup script |

### Infrastructure-as-Code fundamentals
| Folder | What it covers |
|---|---|
| `ARMResourceProject` | ARM template authoring |
| `SimpleBiCEPproject/scripts` | Bicep basics |

### Utility scripts
| File | Purpose |
|---|---|
| `ProjectSpaceCreation.ps1` | Spins up a clean resource group / project scaffold |
| `DeleteAzureSync.ps1` | Teardown script for storage sync issues |
| `unittests.ps1` | Basic test coverage for scripts in this repo |
| `extensions.txt` | VS Code extensions used for this project |

## How to use this repo

Each project folder is self-contained. `cd` into the one you want, check for a script or `.bicep`/`.json` file, and read through it before running; most assume you already have `Connect-AzAccount` or `az login` done and a target subscription set.

```powershell
# Example
cd SampleProject/
./main.ps1
```

OR

```powershell
# Example
cd StorageAccountProject/scripts
./main.ps1
```



## Status

Actively maintained while I finish AZ-104 prep. New folders get added as I work through remaining exam domains.

## About me

MSc in Mobile Computing & Security (Aalto University). Former SRE and IT consultant, now rebuilding toward cloud/security roles through hands-on Azure work. Currently AZ-104, next up SC-300 and SC-200.
