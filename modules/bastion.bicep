param bastionName string
param publicIpAddressId string
param bastionSubnetId string
param location string

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${bastionName}-ipconfig'
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
