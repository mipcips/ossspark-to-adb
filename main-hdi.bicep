param location string = resourceGroup().location
param environment string = 'dev'

var baseName = 'hditoadb-${environment}'
var adminName = 'tdadmin'




module vnets 'hdi-modules/vnets.bicep'= {
  name: 'hditoadbvnets'
  params: {
    baseName: baseName
    location: location
  }
}


module sas 'hdi-modules/sa.bicep' = {
  name: 'hditoadbsas'
  dependsOn:[
    vnets
    sqls
  ]
  params: {
    baseName: baseName
    location: location
    snetId: vnets.outputs.sn1id
    vnetId: vnets.outputs.vnetid
  }
}


module sqls 'hdi-modules/sql.bicep' = {
  name: 'htitoadbsqls'
  dependsOn:[
    vnets
    
  ]
  params: {
    admin: adminName
    baseName: baseName
    location: location
    pw: 'Tested2222**'
    vnetid: vnets.outputs.vnetid
    snetid: vnets.outputs.sn1id
  }
}


module hdi 'hdi-modules/hdispark.bicep' = {
  name: 'hdiclustoadbsas'
  dependsOn: [
    vnets
    sas
    sqls
  ]
  params: {
    baseName: baseName
    location: location
    pw: 'Tested2222**'
    ambDbName: sqls.outputs.ambariDbName
    hiveDbName: sqls.outputs.hiveDbName
    admin: adminName
    saBlobUrl: sas.outputs.saBlobUrl
    snetId: vnets.outputs.sn2id
    vnetId: vnets.outputs.vnetid
    sqlServerFQDN: sqls.outputs.sqlServerFQDN
    saKey: sas.outputs.saKey
    saId: sas.outputs.said
  }
}


