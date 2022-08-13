param baseName string
param location string
param admin string
@secure()
param pw string
param vnetid string
param snetid string

var cleanedBaseName = replace(baseName, '-', '')


resource osssprk 'Microsoft.Sql/servers@2022-02-01-preview'={
  name: 'osssprk${cleanedBaseName}'
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


resource pesql 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'peSql${cleanedBaseName}'
  location: location
  properties: {
    subnet: {
      id: snetid
    } 
    privateLinkServiceConnections: [
     {
       name: 'peSql${cleanedBaseName}'
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

}

resource pDnsZoneSqlLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01'={
  name: 'pDnsZoneSql-link'
  parent: pDnsZoneSql
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetid
    }
  }
}

resource pESqlDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01'= {
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
output sqlServerFQDN string = osssprk.properties.fullyQualifiedDomainName
