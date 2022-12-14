param baseName string
param location string
param admin string
@secure()
param pw string

var cleanedBaseName = replace(baseName, '-', '')


resource osssprk 'Microsoft.Sql/servers@2022-02-01-preview'={
  name: 'hdisql${cleanedBaseName}'
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

output hiveDbName string = hivedb.name
output ambariDbName string = ambdb.name
output sqlServerFQDN string = osssprk.properties.fullyQualifiedDomainName
