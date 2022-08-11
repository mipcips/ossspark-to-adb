param baseName string
param location string
param vnetId string
param snetId string
param admin string = 'tdadmin'
@secure()
param pw string 
param sqlServerFQDN string
param hiveDbName string
param ambDbName string
param saBlobUrl string
param saKey string
param saId string



resource hdispark 'Microsoft.HDInsight/clusters@2021-06-01'={
  name: 'hdi01${baseName}'
  location: location

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
          'javax.jdo.option.ConnectionURL': 'jdbc:sqlserver://${sqlServerFQDN};database=${hiveDbName};encrypt=true;trustServerCertificate=true;create=false;loginTimeout=300'
          'javax.jdo.option.ConnectionUserName': admin
          'javax.jdo.option.ConnectionPassword': pw
         }
         'hive-env' : {
          hive_database : 'Existing MSSQL Server with sql auth'
          hive_database_name: hiveDbName
          hive_database_type: 'mssql'
          hive_existing_mssql_server_database: hiveDbName
          hive_existing_mssql_server_host : sqlServerFQDN
          hive_hostname: sqlServerFQDN
         }
         'ambari-conf': {
          'database-server': sqlServerFQDN
          'database-name': ambDbName
          'database-user-name': admin
          'database-user-password': pw
         }
       }
    }
    storageProfile: {
      storageaccounts: [
         {
          name: replace(replace(saBlobUrl, 'https://', ''), '/', '')
          isDefault: true
          container: 'hdi01${baseName}'
          resourceId: saId
          key: saKey
          
         }
      ]
    }
    networkProperties: {
       resourceProviderConnection: 'Outbound'
       privateLink:'Enabled'
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
             id: vnetId
             subnet: snetId
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
            id: vnetId
            subnet: snetId

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
            id: vnetId
            subnet: snetId
          }
        }
      ]
    }
    
  }
  
}
