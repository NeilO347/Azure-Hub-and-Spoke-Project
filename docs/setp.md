# Phase 1 - Azure Governance Baseline

## Resource Group
- Name: rg-hubspoke-lab
- Region: Central US
- Environment: Lab
- Project: HubSpoke

## Identity and Access Management
- Created Entra security group:
  SG-HubSpoke-Lab-Admins
- Membership: Assigned
- Azure RBAC role: Contributor
- Scope: rg-hubspoke-lab

## Security Approach
- Group-based RBAC rather than individual assignments
- Permissions scoped to the project resource group
- No subscription-wide Contributor access granted