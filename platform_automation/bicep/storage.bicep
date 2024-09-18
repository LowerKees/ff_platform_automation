param containers array
param location string
param skuName string = 'Standard_ZRS'
param storageName string

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_3'
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource service 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for (container, i) in containers: {
  parent: service
  name: container
  properties: {
    publicAccess: 'None'
  }
}]

output storageAccountName string = storage.name
