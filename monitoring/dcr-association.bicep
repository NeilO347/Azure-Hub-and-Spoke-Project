param vmName string = 'vm-app01'
param dcrName string = 'dcr-hubspoke-syslog'

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' existing = {
  name: vmName
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' existing = {
  name: dcrName
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'association-hubspoke-syslog'
  scope: vm
  properties: {
    dataCollectionRuleId: dcr.id
  }
}
