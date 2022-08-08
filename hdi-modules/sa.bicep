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
  }
}

output said string = sa.id
output saName string = sa.name
