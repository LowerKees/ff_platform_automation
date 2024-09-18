@description('Id to make the deployment unique but subdeployments recognizable')
param buildId string = uniqueString(utcNow())
@description('The storage container used for synapse workspace items.')
param primaryContainer string
@description('List of storage containers to deploy additionally.')
param secondaryContainers array
@allowed(['dev', 'tst', 'acc', 'prd'])
@description('The target environment description')
param environment string
@description('Azure region to deploy the resources to. Deploy to South Sweden for the cheapest vCPU price for Spark pools.')
@allowed(['South Sweden', 'Germany West Central', 'West Europe', 'North Europe'])
param location string
@description('A short team name. Only alphanumeric characters. Maximum of eight characters. Should not contain spaces or special chars.')
@maxLength(8)
param shortTeamName string
@description('The SKU used for the primary storage account of the Synapse workspace')
@allowed(['Standard_LRS', 'Standard_ZRS', 'Standard_GRS', 'Standard_GZRS', 'Standard_RAGRS', 'Standard_RAGZRS'])
param skuName string = 'Standard_ZRS'

var containers = union(array(primaryContainer), secondaryContainers)
var environmentLower = toLower(environment)
var shortTeamNameLower = toLower(shortTeamName)
var storageName = 'st${shortTeamNameLower}${environmentLower}'
var synapseName = 'synw-${shortTeamNameLower}-${environmentLower}'

module storage 'storage.bicep' = {
  name: 'deploy-storage-${buildId}'
  params: {
    containers: containers
    storageName: storageName
    location: location
    skuName: skuName
  }
}

module synapse 'synapse.bicep' = {
  name: 'deploy-synapse-workspace-${buildId}'
  params: {
    containerName: primaryContainer
    initialWorkspaceAdminObjectId: '015b609e-2397-4e03-8708-3d9b05fb82a3'  //  entra id admins group 
    storageAccountName: storage.name
    synapseName: synapseName
  }
}

