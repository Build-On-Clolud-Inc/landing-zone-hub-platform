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
param resourceLocation string = deployment().location

@description('Optional. The tags to apply to the resource group.')
param tags object 

@description('Optional. The name of the virtual network.')
param vnetName string

@description('Optional. The address prefix for the virtual network.')
param vnetAddressPrefix array


// Define the subnetAddressPrefixes param
param subnetAddressPrefixes array 


// General resources
// =================
module rg 'br/public:avm/res/resources/resource-group:0.3.0' = {
  name: 'rg01'
  params: {
    name: resourceGroupName
    location: resourceLocation
    tags: tags
  }
}



//Virtual Network
module vnet 'br/public:avm/res/network/virtual-network:1.1.3' = {
  scope: resourceGroup('rg01')
  name: 'vnet01'
  params: {
      name: vnetName
      location: resourceLocation
      addressPrefixes: vnetAddressPrefix
      subnets: [
          for (subnetAddressPrefix, i) in subnetAddressPrefixes: {
              name: 'subnet${i + 1}'
              addressPrefix: subnetAddressPrefix
          }
      ]
  }
}


//Subnets, nsg, route tables, Subnet for bastion /27


//VM with private IP

//bastion

//Firewalls

//Firewall Rules





