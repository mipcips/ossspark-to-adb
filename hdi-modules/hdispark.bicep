param baseName string
param location string
param saName string
param admin string = 'tdadmin'
param snetName string
@secure()
param pw string 


// pull in storage account
resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: saName
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: snetName
}

resource hdispark 'Microsoft.HDInsight/clusters@2021-06-01'={
  name: 'hdi01${baseName}'
  location: location
  dependsOn: [
    sa
    snet
  ]
  properties:{
    clusterVersion: '4.0'
    osType: 'Linux'
    clusterDefinition: {
       kind: 'spark'
       componentVersion:  {
        spark: '3.0'
       }
       configurations: {
         gateway: {
           'restAuthCredential.isEnabled': true 
           'restAuthCredential.username': admin
           'restAuthCredential.password' : pw
         }
       }
    }
    storageProfile: {
      storageaccounts: [
         {
          name: replace(replace(sa.properties.primaryEndpoints.blob, 'https://', ''), '/', '')
          isDefault: true
          container: 'hdi01${baseName}'
          key: sa.listKeys('2021-08-01').keys[0].value
          
         }
      ]
    }
    computeProfile: {
      roles: [
        {
          name: 'headnode'
          targetInstanceCount: 2
          hardwareProfile: {
            vmSize: 'Standard_E4_v3'
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: admin
              password: pw
            }
          }
  
        }
        {
          name: 'workernode'
          targetInstanceCount: 2
          hardwareProfile: {
            vmSize: 'Standard_E4_v3'
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: admin
              password: pw
            }
          }
        }
      ]
    }
  }
}
