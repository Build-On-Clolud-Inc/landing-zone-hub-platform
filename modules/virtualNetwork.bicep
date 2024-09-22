param virtualNetworkName string
param addressPrefix string
param subnets array
param virtualNetworkLocation string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: virtualNetworkLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        }
      }
    ]
  }
}

output virtualNetworkId string = virtualNetwork.id
output subnet01Id string = virtualNetwork.properties.subnets[0].id
