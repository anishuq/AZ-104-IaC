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

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-08-01' = {
   name: storageAccountName
   location: location
   sku: {
     name: skuName
   }
   kind: 'StorageV2'
   properties: {
     accessTier: 'Hot'
   }
 }

 output storageAccountId string = storageAccount.name
