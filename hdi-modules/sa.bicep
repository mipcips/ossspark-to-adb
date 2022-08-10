param baseName string
param location string
param snetId string
param vnetId string

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


resource peBlob 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'peblob${cleanedBaseName}'
  location: location
  properties: {
   privateLinkServiceConnections: [
     {
      name: 'peblob${cleanedBaseName}'
      properties: {
       groupIds: [
        'blob'
       ] 
       privateLinkServiceId: sa.id
       privateLinkServiceConnectionState: {
        status: 'Approved'
        description: 'Auto-Approved'
        actionsRequired: 'None'
       }
      }
     }
   ] 
   subnet: {
    id: snetId
   }
  }
}

resource peFile 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'peFile${cleanedBaseName}'
  location:location
  properties: {
   privateLinkServiceConnections: [
    {
      name: 'peFile${cleanedBaseName}'
      properties: {
       groupIds: [
        'file'
       ] 
       privateLinkServiceId: sa.id
       privateLinkServiceConnectionState: {
        status: 'Approved'
        actionsRequired: 'None'
       }
      }
    }
   ] 
   subnet: {
    id: snetId
   }
  }
}

resource blobpDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}

resource peDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  name: '${peBlob.name}/blob-PrivateDnsZoneGroup}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatellink.blob.${environment().suffixes.storage}'
        properties: {
          privateDnsZoneId: blobpDnsZone.id
        }
      }
    ]
  }
}

resource blobpDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01'= {
  name: '${blobpDnsZone.name}/${uniqueString(sa.id)}'
  location: 'global'
  properties:{
   registrationEnabled: false
   virtualNetwork: {
    id: vnetId
   }   
  }
  
}

resource fileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'global'
}

resource filePeDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01'= {
  name: '${peFile.name}/blob-PrivateDnsZoneGroup'
  properties: {
   privateDnsZoneConfigs: [
    {
      name: 'privatelink.file.${environment().suffixes.storage}'
      properties: {
       privateDnsZoneId: fileDnsZone.id 
      }
    }
   ] 
  }
}

resource filePDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${fileDnsZone.name}/${uniqueString(sa.id)}'
  location: 'global'
  properties: {
   registrationEnabled: false
   virtualNetwork: {
    id: vnetId
   } 
  }
}


output said string = sa.id
output saName string = sa.name
