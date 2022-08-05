param baseName string
param location string


resource sa 'Microsoft.Storage/storageAccounts@2021-09-01'={
  name: 'sa${replace(baseName, '-', '')}'
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
