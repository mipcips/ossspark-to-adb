param baseName string
param location string


var cleanedBaseName = replace(baseName, '-', '')


resource sa 'Microsoft.Storage/storageAccounts@2021-09-01'={
  name: 'sa${uniqueString(resourceGroup().id, cleanedBaseName)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
     isHnsEnabled: false
     accessTier: 'Hot'
     allowBlobPublicAccess: false
     publicNetworkAccess: 'Enabled'
     encryption: {
      keySource:  'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
       blob: {
        enabled: true
        keyType: 'Account'
       } 
       file: {
        enabled: true
        keyType: 'Account'

       }
       queue: {
        enabled: true
        keyType: 'Account'
       }
       table: {
        enabled: true
        keyType: 'Account'
       }
      }
     }
  }
}

resource dlg2 'Microsoft.Storage/storageAccounts@2021-09-01'={
  name: 'dlg2${uniqueString(resourceGroup().id, cleanedBaseName)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
     isHnsEnabled: true
     accessTier: 'Hot'
     allowBlobPublicAccess: false
     publicNetworkAccess: 'Enabled'
     encryption: {
      keySource:  'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
       blob: {
        enabled: true
        keyType: 'Account'
       } 
       file: {
        enabled: true
        keyType: 'Account'

       }
       queue: {
        enabled: true
        keyType: 'Account'
       }
       table: {
        enabled: true
        keyType: 'Account'
       }
      }
     }
  }
}

output said string = sa.id
output saName string = sa.name
output saBlobUrl string = sa.properties.primaryEndpoints.blob
output dlgid string = dlg2.id


