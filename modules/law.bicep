@description('The name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

@description('The location of the Log Analytics workspace.')
param location string

@description('The pricing tier for the Log Analytics workspace.')
param pricingTier string = 'PerGB2018'

@description('The retention period in days for the Log Analytics workspace.')
param retentionInDays int = 30

@description('The tags to apply to the Log Analytics workspace.')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: pricingTier
    }
    retentionInDays: retentionInDays
  }
  tags: tags
}

resource logAnalyticsSharedKeys 'Microsoft.OperationalInsights/workspaces/sharedKeys@2021-06-01' = {
  name: 'listKeys'
  parent: logAnalyticsWorkspace
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceKey string = logAnalyticsSharedKeys.properties.primarySharedKey
