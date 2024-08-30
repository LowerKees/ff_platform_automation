@description('Name of the container to use as default Synapse container')
param containerName string
@description('Object ID of entity that is made the initial admin of the workspace')
param initialWorkspaceAdminObjectId string
param location string = 'Sweden South'
@description('Name of the storage account to link to synapse')
param storageAccountName string
param synapseName string 

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    azureADOnlyAuthentication: true
    defaultDataLakeStorage: {
      accountUrl: storage.properties.primaryEndpoints.dfs
      filesystem: containerName
      createManagedPrivateEndpoint: true
    }
    managedVirtualNetwork: 'default'
    managedResourceGroupName: '${resourceGroup().name}-mgmt'
    cspWorkspaceAdminProperties: {
      initialWorkspaceAdminObjectId: initialWorkspaceAdminObjectId
    }
    publicNetworkAccess: 'Enabled'
  }
}
