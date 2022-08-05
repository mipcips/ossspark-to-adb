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
