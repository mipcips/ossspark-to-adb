param baseName string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01'={
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



resource snet1 'Microsoft.Network/virtualNetworks/subnets@2021-08-01'={
  name: 'snet1-${baseName}'
  parent: vnet
  properties: {
    addressPrefix: '192.168.23.0/25' 
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}


resource snet2 'Microsoft.Network/virtualNetworks/subnets@2021-08-01'= {
  name: 'snet2-${baseName}'
  parent: vnet
  dependsOn: [
    snet1

  ]
  properties: {
    addressPrefix: '192.168.23.128/25' 
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
      id: nsghdi.id
    }
  }
}


resource nsghdi 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsg-${baseName}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'hdinsightrule'
        properties:{
          access: 'Allow'
          protocol: '*'
          direction: 'Inbound'
          sourcePortRange:'*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'HDInsight'
          destinationAddressPrefix: 'VirtualNetwork'
          priority: 300
        }
                 
      } 
      {
        name: 'resolver'
        properties: {
          access: 'Allow'
          protocol: '*'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '192.63.129.16'
          destinationAddressPrefix: 'VirtualNetwork'
          priority: 301
        }
      }
    ] 
  }
}

output sn1id string = snet1.id
output sn2id string = snet2.id
output sn1name string = snet1.name
output vnetName string = vnet.name
output vnetid string = vnet.id
