//This script assumes that the resource group 
//is already created and the location is set to the resource group location.
@minLength(3)
@maxLength(24)
param storageAccountName string 
param location string = resourceGroup().location

@description('The SKU of the storage account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param skuName string = 'Standard_LRS'

var uniqueSuffix = toLower((substring(uniqueString(resourceGroup().id), 0, 6)))
var uniqueStrAccName = 'str${storageAccountName}${uniqueSuffix}'
var regions = [
  'eastus'
  'canadacentral'
  'westeurope'
]

module storageAccountModule './storageaccount.bicep' = [for (region,i) in regions: {
  name: 'strAccModuleDeployment${i}'
  params: {
    storageAccountName: '${uniqueStrAccName}${i}'
    skuName: skuName
    location: region
  }
}]

module webAppModule './webapp.bicep' = {
  name: 'webAppModuleDeployment'
  params: {
    name: 'webapp-${uniqueSuffix}'
    location: regions[1]
    storageEndpoint: storageAccountModule[0].outputs.endpoint
  }
}


output webAppsURL string = webAppModule.outputs.url


