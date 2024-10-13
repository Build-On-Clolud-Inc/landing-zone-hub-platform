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

@description('Optional. The name of the bastion.')
param bastionName string

@description('Optional. The name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

@description('Optional. The retention period in days for Log Analytics data.')
param lawRetentionInDays int

@description('Optional. The name of the key vault.')
param keyVaultName string

@description('Optional. The tags for the Log Analytics workspace.')
param tags object


// General resources
// =================
// module rg 'modules/resourceGroup.bicep' = {
//   scope: subscription()
//   name: 'resourceGroup'
//   params: {
//     location: resourceLocation
//     resourceGroupName: resourceGroupName
//   }
// }
resource hubrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {  
  name: resourceGroupName
  location: resourceLocation
}


module pip 'modules/pip.bicep' = {
  scope: hubrg
  name: 'pip01'
  params: {
    publicIpName: publicIpName
    location: resourceLocation
    publicIpSku: publicIpSku
  }
}

module vnet 'modules/virtualNetwork.bicep' = {
  scope: hubrg
  name: 'vnet01'
  params: {
    virtualNetworkName: vnetName
    virtualNetworkLocation: resourceLocation
    addressPrefix: vnetAddressPrefix
    subnets: subnets
  }
}

//make a call to the bastion module
module bastion 'modules/bastion.bicep' = {
  scope: hubrg
  name: 'bastion01'
  params: {
    bastionName: bastionName
    publicIpAddressId: pip.outputs.publicIpId
    bastionSubnetId: vnet.outputs.subnet01Id
  }
}

module logAnalytics 'modules/law.bicep' = {
  scope: hubrg  
  name: 'logAnalyticsDeployment'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: resourceLocation
    retentionInDays: lawRetentionInDays
    tags: tags
  }
}

//VM with private IP
module pass 'modules/password.bicep' = {
  scope: hubrg
  name: 'pass1'
  params: {
    location: resourceLocation
  }
}

module keyvault 'modules/keyVault.bicep' = {
  name: 'kv-qwr-deployment'
  scope: hubrg
  params: {
    location: resourceLocation
    keyVaultName: keyVaultName
    enabledForTemplateDeployment: true
    virtualNetworkRules: [
      {
        id: vnet.outputs.subnet02Id
        ignoreMissingVnetServiceEndpoint: true
      }
    ]
    secrets: [
      {
        name: 'VMPassword'
        value: pass.outputs.result
      }
    ]
  }
}


module vm1 'modules/virtualMachine.bicep' = {
  name: 'vm1'
  scope: hubrg
  params: {     
    location: resourceLocation
    nicName: 'winnic'
    subnetId: vnet.outputs.subnet02Id
    vmName: 'vm120241013'
    vmSize: 'Standard_B2s'
    authenticationType: 'password'
    adminUsername: 'adminuser'
    adminPasswordOrPublicKey: pass.outputs.result
    operatingSystem: 'Windows' 
    operatingSystemSKU: 'winServer19' // Available values are "'win10','winServer19', 'ubuntu2004', 'ubuntu2004gen2'"    
    WorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    WorkspaceKey: logAnalytics.outputs.logAnalyticsWorkspaceKey
  }
}

//Latest
//we provisioned kv but looks like there is a problem with either log analytics shared key 
//ajinkya saying to delete the rg and reprovision it
//we need to figure the key to log analytics that we pass to vm wy there is a problem



//Firewalls : Subnets, nsg, route tables


//Firewall Rules

//Host your org's GitHub runners in Azure Container Apps
//https://blog.xmi.fr/posts/github-runner-container-app-part1/

//After hub, on a separate pipeline, we will deploy spoke resources
