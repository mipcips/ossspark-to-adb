param baseName string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01'={
  name: 'vneta-${baseName}'
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
         '192.168.23.0/24'
       ]
     }
  }
}



resource snet1 'Microsoft.Network/virtualNetworks/subnets@2022-01-01'={
  name: 'snet1-${baseName}'
  parent: vnet
  properties: {
    addressPrefix: '192.168.23.0/25' 

  }
}


resource snet2 'Microsoft.Network/virtualNetworks/subnets@2022-01-01'= {
  name: 'snet2-${baseName}'
  parent: vnet
  properties: {
    addressPrefix: '192.168.23.128/25' 
  }
}

output sn1id string = snet1.id
output sn2id string = snet2.id
output sn1name string = snet1.name
