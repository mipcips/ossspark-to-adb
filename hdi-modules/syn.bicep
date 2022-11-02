param baseName string
param location string 

@secure()
param adminPassword string


var cleanedBaseName = replace(baseName, '-', '')

resource synstoacct 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'syndlg2${cleanedBaseName}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    isHnsEnabled: true
  }

}

resource fs 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${synstoacct.name}/default/fs${baseName}01'
 
}

resource synws 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: 'synws-${baseName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    defaultDataLakeStorage: {
      accountUrl: synstoacct.properties.primaryEndpoints.dfs
      filesystem: fs.name
    }

    sqlAdministratorLogin: 'tdadmin'
    sqlAdministratorLoginPassword: adminPassword
    workspaceRepositoryConfiguration:  {
      
    }
  }
  
  
}


resource fwrule1 'Microsoft.Synapse/workspaces/firewallRules@2019-06-01-preview' = {
  name: '${synws.name}/fwallowall'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
  
}

resource fwrule2 'Microsoft.Synapse/workspaces/firewallRules@2019-06-01-preview' = {
  name: '${synws.name}/AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
  
}

resource micontrol 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2019-06-01-preview' = {
  name: '${synws.name}/default'
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
  
}


var roleDefinitionResourceId = resourceId('Microsoft.Authorization/roleDefinitions','ba92f5b4-2d11-453d-a403-e96b0029c9fe')


// role assignment storage blob data contributor
resource synsara 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: synstoacct
  name: guid(synstoacct.id, synws.id, roleDefinitionResourceId)
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: synws.identity.principalId
    principalType: 'ServicePrincipal'
    
  }

}
