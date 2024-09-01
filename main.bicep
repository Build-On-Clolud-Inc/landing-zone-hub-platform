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
