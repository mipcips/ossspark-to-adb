param location string = resourceGroup().location
param environment string = 'dev'
@secure()
param pw string
param adbMngResourceGroupName string

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
  }
}


module sqls 'hdi-modules/sql.bicep' = {
  name: 'htitoadbsqls'
  dependsOn:[
    vnets
    
  ]
  params: {
    baseName: baseName
    location: location
    admin: adminName
    pw: pw
  
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
    pw: pw
    ambDbName: sqls.outputs.ambariDbName
    hiveDbName: sqls.outputs.hiveDbName
    admin: adminName
    saBlobUrl: sas.outputs.saBlobUrl
    snetId: vnets.outputs.hdinetId
    vnetId: vnets.outputs.vnetid
    sqlServerFQDN: sqls.outputs.sqlServerFQDN
    saName: sas.outputs.saName
    saId: sas.outputs.said
  }
}


module vm 'hdi-modules/vm.bicep' = {
  name: 'vmhditoadb'
  params: {
    adminPw: pw
    adminUser: adminName
    baseName: baseName
    genPSubId: vnets.outputs.genPNetId
    location: location
    nsgId: vnets.outputs.nsgVmId
  }
}


module adb 'hdi-modules/adb.bicep' = {
  name: 'adbwshditoadb'
  dependsOn: [
    vnets
  ]
  params: {
    baseName: baseName
    location: location
    privSnetName: vnets.outputs.adbpriName
    pubSnetName: vnets.outputs.adbPubName
    vnetId: vnets.outputs.vnetid
    adbMngResourceGroupName: adbMngResourceGroupName
  }
}
