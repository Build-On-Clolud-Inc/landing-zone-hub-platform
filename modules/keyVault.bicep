param location string
param keyVaultName string
param enabledForTemplateDeployment bool = true
param virtualNetworkRules array = []
param secrets array = []

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForTemplateDeployment: enabledForTemplateDeployment
    networkAcls: {
      virtualNetworkRules: virtualNetworkRules
    }
  }
}

resource secretsResource 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret in secrets: {
  parent: keyVault
  name: secret.name
  properties: {
    value: secret.value
  }
}]
