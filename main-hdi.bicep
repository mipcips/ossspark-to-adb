param location string = resourceGroup().location
param environment string = 'dev'

var baseName = 'hditoadb-${environment}'


module vnets 'hdi-modules/vnets.bicep'= {
  name: 'hditoadbvnets'
  params: {
    baseName: baseName
    location: location
  }
}


module sas 'hdi-modules/sa.bicep' = {
  name: 'hditoadbsas'
  params: {
    baseName: baseName
    location: location
  }
}


module hdi 'hdi-modules/hdispark.bicep' = {
  name: 'hdiclustoadbsas'
  params: {
    baseName: baseName
    location: location
    pw: 'Tested2222**'
    saName: sas.outputs.saName
    snetName: vnets.outputs.sn1name
  }
}
