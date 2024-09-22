targetScope = 'subscription'

metadata name = 'Ehsan Eskadnari example'
metadata description = 'Ehsan Eskadnari example'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string

@description('Optional. The location to deploy resources to.')
param resourceLocation string

@description('Optional. The name of the virtual network.')
param vnetName string

@description('Optional. The address prefix for the virtual network.')
param vnetAddressPrefix string

@description('Optional. The subnets for the virtual network.')
param subnets array

@description('Optional. The name of the public IP.')
param publicIpName string

@description('Optional. The SKU of the public IP.')
param publicIpSku string


// General resources
// =================
module rg 'modules/resourceGroup.bicep' = {
  scope: subscription()
  name: 'resourceGroup'
  params: {
    location: resourceLocation
    resourceGroupName: resourceGroupName
  }
}



module pip 'modules/pip.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'pip01'
  params: {
    publicIpName: publicIpName
    location: resourceLocation
    publicIpSku: publicIpSku
  }
}

module vnet 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'vnet01'
  params: {
    virtualNetworkName: vnetName
    virtualNetworkLocation: resourceLocation
    addressPrefix: vnetAddressPrefix
    subnets: subnets
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
