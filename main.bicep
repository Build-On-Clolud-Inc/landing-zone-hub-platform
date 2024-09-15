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

@description('Optional. The tags to apply to the resource group.')
param tags object

@description('Optional. The name of the virtual network.')
param vnetName string

@description('Optional. The address prefix for the virtual network.')
param vnetAddressPrefix string

// Define the subnetAddressPrefixes param
param subnetAddressPrefixes array

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

module vnet 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup('rg-sbx-landingzone-eastus-001')
  name: 'vnet01'
  params: {
    virtualNetworkName: vnetName
    virtualNetworkLocation: resourceLocation
    addressPrefix: vnetAddressPrefix
    subnets: [
      for (subnetAddressPrefix, i) in subnetAddressPrefixes: {
        name: 'subnet${i + 1}'
        addressPrefix: subnetAddressPrefix
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
