//This script assumes that the ressource group 
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

module storageAccountModule './storageaccount.bicep' = {
  name: 'strAccModuleDeployment'
  params: {
    storageAccountName: uniqueStrAccName
    skuName: skuName
    location: location
  }
}

module webAppModule './webapp.bicep' = {
  name: 'webAppModuleDeployment'
  params: {
    name: 'webapp-${uniqueSuffix}'
    location: location
    storageEndpoint: storageAccountModule.outputs.endpoint
  }
}

output webappurl string = webAppModule.outputs.url
