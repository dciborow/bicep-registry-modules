param aksName string
@description('Deployment Location')
param location string

@description('Secondary Deployment Locations')
param secondaryLocations array = []

param resourceGroupName string = resourceGroup().name
param publicIpName string
param keyVaultName string
param servicePrincipalClientID string
param workerServicePrincipalClientID string = servicePrincipalClientID
param hostname string
param setup bool = true

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

param azureTenantID string = subscription().tenantId
param keyVaultTenantID string = subscription().tenantId
param loginTenantID string = subscription().tenantId

param namespace string = ''

@description('Delete old ref records no longer in use across the entire system')
param CleanOldRefRecords bool = true

@description('Delete old blobs that are no longer referenced by any ref - this runs in each region to cleanup that regions blob stores')
param CleanOldBlobs bool = true

var locations = union([ location ], secondaryLocations)

module ddcSetup 'ddc-umbrella.bicep' = [for (location, index) in locations: {
  name: 'helmInstall-ddc-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    aksName: aksName
    location: location
    resourceGroupName: resourceGroupName
    keyVaultName: take('${location}-${keyVaultName}', 24)
    servicePrincipalClientID: servicePrincipalClientID
    workerServicePrincipalClientID: workerServicePrincipalClientID
    hostname: hostname
    keyVaultTenantID: keyVaultTenantID
    loginTenantID: loginTenantID
    enableWorker: !empty(secondaryLocations)
    namespace: namespace
    CleanOldRefRecords: !contains(secondaryLocations, location) ? CleanOldRefRecords : false
    CleanOldBlobs: CleanOldBlobs
  }
}]

module configAKS 'ContainerService/configure-aks.bicep' = [for (location, index) in locations: if(setup) {
  name: 'configAKS-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    location: location
    aksName: '${aksName}-${take(location, 8)}'
    additionalCharts: [ ddcSetup[index].outputs.helmChart ]
    staticIP: '${publicIpName}-${location}'
    azureTenantID: azureTenantID
  }
}]


module combo 'ContainerService/helmChartInstall.bicep' = [for (location, index) in locations: if(!setup) {
  name: 'helmInstall-UnrealCloud-${uniqueString(aksName, location, resourceGroup().name)}'
  params: {
    aksName: '${aksName}-${take(location, 8)}'
    location: location
    helmCharts: [ddcSetup[index].outputs.helmChart]
    useExistingManagedIdentity: true
    managedIdentityName: 'id-${aksName}-${location}'
    existingManagedIdentitySubId: existingManagedIdentitySubId
    existingManagedIdentityResourceGroupName: existingManagedIdentityResourceGroupName
  }
}]