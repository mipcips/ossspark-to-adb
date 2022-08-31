param baseName string
param location string 
param vnetId string
param pubSnetName string
param privSnetName string


var workSpaceName = 'adb-${baseName}'
var mngResourceGroupName = 'databricks-rg-${workSpaceName}-${uniqueString(workSpaceName, resourceGroup().id)}'

resource mngResGroup 'Microsoft.Resources/resourceGroups@2021-04-01'  existing = {
  scope: subscription()
  name: mngResourceGroupName
}

resource adb 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: 'adb-${baseName}'
  location: location
  sku: {
    name: 'premium'
  }
  properties: {
    managedResourceGroupId:  mngResGroup.id
    parameters: {
      customVirtualNetworkId: {
        value: vnetId
      }
      customPrivateSubnetName: {
        value: privSnetName
      }
      customPublicSubnetName: {
        value: pubSnetName
      }
      enableNoPublicIp: {
        value: true
      }
    }
  }
}
