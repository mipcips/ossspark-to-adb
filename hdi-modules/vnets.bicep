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
  name: 'hdi-${baseName}'
  parent: vnet
  properties: {
    addressPrefix: '192.168.23.0/26' 
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
      id: nsghdi.id
    }
  }
}


resource snet2 'Microsoft.Network/virtualNetworks/subnets@2021-08-01'= {
  name: 'gen-${baseName}'
  parent: vnet
  dependsOn: [
    snet1
  ]
  properties: {
    addressPrefix: '192.168.23.64/26' 
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'

  }
}

resource snet3 'Microsoft.Network/virtualNetworks/subnets@2021-08-01'= {
  name: 'adbpri-${baseName}'
  parent: vnet
  dependsOn: [
    snet2
  ]
  properties: {
    addressPrefix: '192.168.23.128/26' 
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
      id: nsgadb.id
    }
    delegations: [
      {
        name: 'databricks-del-private'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
  }
}

resource snet4 'Microsoft.Network/virtualNetworks/subnets@2021-08-01'= {
  name: 'adbpub-${baseName}'
  parent: vnet
  dependsOn: [
    snet3

  ]
  properties: {
    addressPrefix: '192.168.23.192/26' 
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
      id: nsgadb.id
    }
    delegations: [
      {
        name: 'databricks-del-public'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
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


resource nsgadb 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsgadb-${baseName}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
          description: 'Required for workers communication with Databricks Webapp.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureDatabricks'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
          description: 'Required for workers communication with Azure SQL services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 101
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
          description: 'Required for workers communication with Azure Storage services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 102
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
          description: 'Required for worker communication with Azure Eventhub services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9093'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 104
          direction: 'Outbound'
        }
      }
    ]
  }
}

output hdinetId string = snet1.id
output genPNetId string = snet2.id
output adbpriId string = snet3.id
output adbPubId string = snet4.id
output hdiNetName string = snet1.name
output vnetName string = vnet.name
output vnetid string = vnet.id
