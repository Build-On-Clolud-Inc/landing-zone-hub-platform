@description('The name of the resource group.')
param resourceGroupName string

@description('The location of the resource group.')
param resourceLocation string

@description('The name of the virtual network.')
param vnetName string

@description('The address prefix for the virtual network.')
param vnetAddressPrefix string

@description('Array of subnets with names and address prefixes')
param subnets array

@description('The name of the public IP address for the Bastion.')
param publicIpName string

@description('The SKU of the public IP address for the Bastion.')
param publicIpSku string = 'Standard'

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: resourceLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
  }
}

// Public IP for Bastion
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: resourceLocation
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Bastion Host
resource bastionHost 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: 'myBastionHost'
  location: resourceLocation
  properties: {
    ipConfigurations: [
      {
        name: 'bastionHostIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

// //Virtual Network
// module vnet 'br/public:avm/res/network/virtual-network:0.4.0' = {
//   scope: resourceGroup('rg-sbx-landingzone-eastus-001')
//   name: 'vnet01'
//   params: {
//       name: vnetName
//       location: resourceLocation
//       addressPrefixes: vnetAddressPrefix
//       subnets: [
//           for (subnetAddressPrefix, i) in subnetAddressPrefixes: {
//               name: 'subnet${i + 1}'
//               addressPrefix: subnetAddressPrefix
//           }
//       ]
//   }
// }

//Subnets, nsg, route tables, Subnet for bastion /27

//VM with private IP

//bastion

//Firewalls

//Firewall Rules
