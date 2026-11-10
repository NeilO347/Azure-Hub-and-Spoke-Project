param location string = resourceGroup().location

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: 'law-hubspoke-lab'
}

resource syslogDcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-hubspoke-syslog'
  location: location
  properties: {
    dataSources: {
      syslog: [
        {
          name: 'linux-syslog'
          streams: [
            'Microsoft-Syslog'
          ]
          facilityNames: [
            'auth'
            'authpriv'
            'daemon'
          ]
          logLevels: [
            'Warning'
            'Error'
            'Critical'
            'Alert'
            'Emergency'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'lab-workspace'
          workspaceResourceId: workspace.id
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          'lab-workspace'
        ]
      }
    ]
  }
}

output dcrId string = syslogDcr.id
