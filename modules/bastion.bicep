param bastionName string
param publicIpAddressId string
param bastionSubnetId string

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionName
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: publicIpAddressId
          }
        }
      }
    ]
  }
}

output bastionResourceId string = bastion.id
