
targetScope = 'resourceGroup'

param location string = resourceGroup().location

// Hub network
resource hubVnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-hub'
  location: location
  tags: {
    Environment: 'Lab'
    Project: 'HubSpoke'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-management'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id:hubNsg.id
          }
        }
      }
    ]
  }
}

// Application spoke
resource appVnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-spoke-app'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-app'
        properties: {
          addressPrefix: '10.1.1.0/24'
          networkSecurityGroup: {
            id: appNsg.id
          }
        }
      }
    ]
  }
}

// Administration spoke
resource adminVnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-spoke-admin'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-admin'
        properties: {
          addressPrefix: '10.2.1.0/24'
          networkSecurityGroup:{
            id: adminNsg.id
          }
        }
      }
    ]
  }
}




 // Hub to Application Spoke
resource hubToApp 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: hubVnet
  name: 'hub-to-app'
  properties: {
    remoteVirtualNetwork: {
      id: appVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
  }
}

// Application Spoke to Hub
resource appToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: appVnet
  name: 'app-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
  }
}

// Hub to Administration Spoke
resource hubToAdmin 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: hubVnet
  name: 'hub-to-admin'
  properties: {
    remoteVirtualNetwork: {
      id: adminVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
  }
}

// Administration Spoke to Hub
resource adminToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: adminVnet
  name: 'admin-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
  }
}


resource hubNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-hub'
  location: location
  properties: {
    securityRules: []
  }
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-app'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-From-Hub'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Deny-Other-Inbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource adminNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-admin'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-From-Hub'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}



param adminPublicKey string

module appVM './compute.bicep' = {
  name: 'deploy-app-vm'
  params: {
    location: location
    vmName: 'vm-app01'
    adminUsername: 'azureadmin'
    adminPublicKey: adminPublicKey
    vmSize : 'Standard_D2alds_v6'
    subnetId: resourceId(
      'Microsoft.Network/virtualNetworks/subnets',
      'vnet-spoke-app',
      'snet-app'
    )
  }
  dependsOn: [
    appVnet
  ]
}



module managementVM './compute.bicep' = {
  name: 'deploy-management-vm'
  params: {
    location: location
    vmName: 'vm-mgmt01'
    adminUsername: 'azureadmin'
    adminPublicKey: adminPublicKey
    vmSize: 'Standard_D2alds_v6'
    subnetId: resourceId(
      'Microsoft.Network/virtualNetworks/subnets',
      'vnet-hub',
      'snet-management'
    )
  }
  dependsOn: [
    hubVnet
  ]
}


module monitoring '../monitoring/monitoring.bicep' = {
  name: 'deploy-monitoring'
  params: {
    location: location
  }
}
