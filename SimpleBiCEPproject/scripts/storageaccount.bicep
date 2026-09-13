param location string 
param storageAccountName string
param skuName string

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

 output storageAccountId string = storageAccount.id
 output endpoint string = storageAccount.properties.primaryEndpoints.blob


