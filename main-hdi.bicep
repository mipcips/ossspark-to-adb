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

/*
module hdi 'hdi-modules/hdispark.bicep' = {
  name: 'hdiclustoadbsas'
  params: {
    baseName: baseName
    location: location
    pw: 'Tested2222**'
    saName: sas.outputs.saName
    snetName: vnets.outputs.sn1name
    ambDbName: sqls.outputs.ambariDbName
    hiveDbName: sqls.outputs.hiveDbName
    sqlServerName: sqls.outputs.ossprkName
    admin: adminName
    vnetName: vnets.outputs.vnetName
  }
}

*/
