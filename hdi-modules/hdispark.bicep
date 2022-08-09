param baseName string
param location string
param saName string
param admin string = 'tdadmin'
param snetName string
@secure()
param pw string 
param sqlServerName string
param hiveDbName string
param ambDbName string
param vnetName string



// pull in storage account
resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: saName
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: snetName
}

resource ossprk 'Microsoft.Sql/servers@2022-02-01-preview' existing = {
  name: sqlServerName
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing={
  name: vnetName
}

resource hdispark 'Microsoft.HDInsight/clusters@2021-06-01'={
  name: 'hdi01${baseName}'
  location: location
  dependsOn: [
    sa
    vnet
    snet
    ossprk
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
         'hive-site': {
          'javax.jdo.option.ConnectionDriverName': 'com.microsoft.sqlserver.jdbc.SqlServerDriver'
          'javax.jdo.option.ConnectionURL': 'jdbc:sqlserver://${ossprk.properties.fullyQualifiedDomainName};database=${hiveDbName};encrypt=true;trustServerCertificate=true;create=false;loginTimeout=300'
          'javax.jdo.option.ConnectionUserName': admin
          'javax.jdo.option.ConnectionPassword': pw
         }
         'hive-env' : {
          hive_database : 'Existing MSSQL Server with sql auth'
          hive_database_name: hiveDbName
          hive_database_type: 'mssql'
          hive_existing_mssql_server_database: hiveDbName
          hive_existing_mssql_server_host : ossprk.properties.fullyQualifiedDomainName
          hive_hostname: ossprk.properties.fullyQualifiedDomainName
         }
         'ambari-conf': {
          'database-server': ossprk.properties.fullyQualifiedDomainName
          'database-name': ambDbName
          'database-user-name': admin
          'database-user-password': pw
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
          virtualNetworkProfile: {
             id: vnet.id
             subnet: snet.id
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
          virtualNetworkProfile:{
            id: vnet.id
            subnet: snet.id

          }
        }
        {
          name: 'zookeepernode'
          minInstanceCount: 1
          targetInstanceCount: 3
          hardwareProfile: {
            vmSize: 'Small'
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: admin
              password: pw
            }
          
          }
          virtualNetworkProfile: {
            id: vnet.id
            subnet: snet.id
          }
        }
      ]
    }
    
  }
  
}
