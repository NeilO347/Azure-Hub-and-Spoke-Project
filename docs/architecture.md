
flowchart TB
    subgraph Azure["Azure — rg-hubspoke-lab"]
        subgraph Hub["Hub VNet — 10.0.0.0/16"]
            Mgmt["Management Subnet — 10.0.1.0/24<br/>vm-mgmt01"]
        end

        subgraph App["App Spoke — 10.1.0.0/16"]
            AppVM["App Subnet — 10.1.1.0/24<br/>vm-app01"]
        end

        subgraph Admin["Admin Spoke — 10.2.0.0/16"]
            AdminSubnet["Admin Subnet — 10.2.1.0/24"]
        end

        Monitor["Azure Monitor Agent"]
        Logs["Log Analytics Workspace<br/>law-hubspoke-lab"]
    end

    Mgmt <-->|VNet Peering| AppVM
    Mgmt <-->|VNet Peering| AdminSubnet
    AppVM --> Monitor --> Logs
