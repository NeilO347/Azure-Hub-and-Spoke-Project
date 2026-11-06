# Secure Hub-and-Spoke Azure Environment (Infrastructure as Code + Troubleshooting)

A hands-on Azure administration project that goes beyond the Microsoft AZ-104 labs. Instead of building one service at a time through the portal, this project builds a single connected, governed, monitored environment as code, then deliberately breaks it and diagnoses the failures the way a cloud support or admin engineer would.

## Goal

Demonstrate real-world Azure administration skills across identity, governance, networking, compute, monitoring, and recovery, and show the ability to deploy repeatably and troubleshoot systematically.

## What This Project Covers

| Area | What was built |
|---|---|
| **Governance** | Group-based RBAC with least-privilege role assignments, plus Azure Policy (required tags, allowed regions, deny public IPs on NICs) |
| **Networking** | Hub-and-spoke topology with VNet peering, NSGs, and user-defined routes, deployed with Bicep |
| **Secure access** | Azure Bastion for VM access, so no VM has a public IP; credentials stored in Azure Key Vault |
| **Compute** | VMs in each spoke, deployed from the same template |
| **Monitoring** | Central Log Analytics workspace, diagnostic settings, Azure Monitor Agent, alert rules with an email action group, and KQL queries for common investigations |
| **Backup and recovery** | Recovery Services vault, backup policy, and a tested restore |
| **Troubleshooting** | Intentional break/fix scenarios diagnosed with Network Watcher, the Activity Log, and KQL |

## Architecture

_Add architecture diagram here (`docs/architecture.png`)._

```
                    +------------------+
                    |       Hub        |
                    |  Bastion, Logs   |
                    +--------+---------+
                       peering | peering
              +----------------+----------------+
              |                                 |
      +-------+--------+               +--------+-------+
      |    Spoke A     |               |    Spoke B     |
      |   VM + NSG     |               |   VM + NSG     |
      +----------------+               +----------------+
```

## Repository Structure

```
.
├── bicep/              # Infrastructure as code templates
├── policies/           # Azure Policy definitions and assignments
├── kql/                # Saved KQL queries (failed sign-ins, NSG changes, etc.)
├── runbooks/           # Break/fix write-ups (symptom, tools, root cause, fix)
├── docs/               # Diagrams and screenshots
└── README.md
```

## Break/Fix Scenarios

Each scenario is documented as: **symptom → tools used → root cause → fix**.

1. NSG rule blocking traffic between spokes
2. User-defined route sending traffic to a black hole
3. Deleted VNet peering
4. DNS resolution failure
5. Removed role assignment causing an access-denied error

## Cost Notes

Built to stay low-cost: small VM sizes, Bastion Developer SKU where possible, no Azure Firewall, resources deallocated between sessions, and a full teardown at the end.

## Skills Demonstrated

Azure administration, RBAC, Azure Policy, Bicep/IaC, virtual networking, Azure Monitor and Log Analytics, KQL, backup and recovery, network troubleshooting, and technical documentation.
