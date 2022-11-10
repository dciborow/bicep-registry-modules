param aksName string
@description('Deployment Location')
param location string = resourceGroup().location

@description('Secondary Deployment Locations')
param secondaryLocations array = []

param resourceGroupName string = resourceGroup().name
param publicIpName string
param keyVaultName string
param servicePrincipalClientID string
param hostname string
param setup bool = true

var locations = union([ location ], secondaryLocations)

module hordeSetup 'horde-umbrella.bicep' = [for (location, index) in locations: {
  name: 'helmInstallHorde-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    location: location
    resourceGroupName: resourceGroupName
    keyVaultName: take('${location}-${keyVaultName}', 24)
    servicePrincipalClientID: servicePrincipalClientID
    hostname: hostname
  }
}]

module configAKS 'ContainerService/configure-aks.bicep' = [for (location, index) in locations: if(setup) {
  name: 'configAKS-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    location: location
    aksName: '${aksName}-${take(location, 8)}'
    additionalCharts: [ hordeSetup[index].outputs.helmChart ]
    staticIP: '${publicIpName}-${location}'
  }
}]


module combo 'ContainerService/helmChartInstall.bicep' = [for (location, index) in locations: if(!setup) {
  name: 'helmInstall-UnrealCloud-${uniqueString(aksName, location, resourceGroup().name)}'
  params: {
    aksName: '${aksName}-${take(location, 8)}'
    location: location
    helmCharts: [hordeSetup[index].outputs.helmChart]
  }
}]
