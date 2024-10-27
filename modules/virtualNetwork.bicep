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
output subnetId array = [ for i in range(0,1): {
  id: virtualNetwork.properties.subnets[i].id
}]
