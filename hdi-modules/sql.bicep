param baseName string
param location string
param admin string
@secure()
param pw string
param vnetName string


var cleanedBaseName = replace(baseName, '-', '')

resource vnets 'Microsoft.Network/virtualNetworks@2022-01-01' existing={
  name: vnetName
}

resource osssprk 'Microsoft.Sql/servers@2022-02-01-preview'={
  name: 'osssprk${cleanedBaseName}'
  dependsOn: [
    vnets
  ]
  location: location
  properties: {
    administratorLogin: admin
    administratorLoginPassword: pw
  }
  
}

resource fwrules 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview'= {
  name: 'fwrules-${baseName}'
  parent: osssprk
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0' 
  }
}

resource hivedb 'Microsoft.Sql/servers/databases@2022-02-01-preview'= {
  name: 'hivedb${cleanedBaseName}'
  parent: osssprk
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    
  }
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}

resource ambdb 'Microsoft.Sql/servers/databases@2022-02-01-preview'= {
  name: 'ambdb${cleanedBaseName}'
  parent: osssprk
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    
  }
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}


resource pesql 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'pe${cleanedBaseName}'
  location: location
  properties: {
    subnet: {
      id: vnets.properties.subnets[0].id
    } 
    privateLinkServiceConnections: [
     {
       name: 'pe${cleanedBaseName}'
       properties: {
         privateLinkServiceId: osssprk.id
         groupIds: [
           'sqlServer'
         ]
       }
       
     } 
    ]
  }
}

resource pDnsZoneSql 'Microsoft.Network/privateDnsZones@2020-06-01'={
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
  location: 'global'
  properties: { }
  dependsOn: [
   vnets 
  ]
}

resource pDnsZoneSqlLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01'={
  name: 'pDnsZoneSql-link'
  parent: pDnsZoneSql
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnets.id
    }
  }
}

resource pESqlDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01'= {
  name: '${pesql.name}/pESqlDnsGroupName'
  properties: {
     privateDnsZoneConfigs: [
       {
        name: 'configsql'
        properties: {
          privateDnsZoneId: pDnsZoneSql.id
        }
       }
     ]
  }
}

output ossprkName string = osssprk.name
output hiveDbName string = hivedb.name
output ambariDbName string = ambdb.name
