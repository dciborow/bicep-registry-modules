param aksName string
@description('Deployment Location Specs')
param locationSpecs array

param resourceGroupName string = resourceGroup().name
param publicIpNamePrefix string
param useVnet bool
param servicePrincipalClientID string
param workerServicePrincipalClientID string = servicePrincipalClientID
param hostname string
param certificateName string

param managedIdentityPrefix string = 'id-ddc-storage-'

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

param azureTenantID string = subscription().tenantId
param keyVaultTenantID string = subscription().tenantId
param loginTenantID string = subscription().tenantId

@description('Delete old ref records no longer in use across the entire system')
param CleanOldRefRecords bool = true

@description('Delete old blobs that are no longer referenced by any ref - this runs in each region to cleanup that regions blob stores')
param CleanOldBlobs bool = true

param helmVersion string = 'latest'

param helmChart string
param helmName string
param helmNamespace string
param siteNamePrefix string

@description('Reference to the container registry repo with the cloud DDC container image')
param containerImageRepo string
@description('The cloud DDC container image version to use')
param containerImageVersion string

@description('Set to false to deploy from as an ARM template for debugging')
param isApp bool = true

@description('Array of ddc namespaces to replicate if there are secondary regions')
param namespacesToReplicate array = []

@description('This is used to scale up the number of pods (replicas) for the main deployment, so that there is one replica per node on the agent')
param mainReplicaCount int

@description('Whether to use a local ephemeral Persistent Volume provisioner for the cluster')
param enableLocalPVProvisioner bool = true

param privateDnsZoneName string
param loadBalancerSubnetName string

resource publicIPs 'Microsoft.Network/publicIPAddresses@2021-03-01' existing = [for spec in locationSpecs: {
  name: '${publicIpNamePrefix}-${spec.location}'
}]

// Need to find available IP address for each location for internal load balancer.
module findAvailableIPs './network/listAvailableIP.bicep' = [for spec in locationSpecs: {
  name: 'findAvailableIPs-${spec.regionCode}-${uniqueString(spec.location, resourceGroup().id, deployment().name)}'
  params: {
    location: spec.location
    vnetName: spec.vnetName
    subnetName: loadBalancerSubnetName
    managedIdentityName: spec.clusterIdentityName
    managedIdentityResourceGroup: resourceGroupName
    enableScript: useVnet
  }
}]

var privateLocationHostNames = [for spec in locationSpecs: '${spec.regioncode}.${privateDnsZoneName}']

module ddcSetup 'ddc-umbrella.bicep' = [for (spec, index) in locationSpecs: {
  name: 'helmInstall-ddc-${uniqueString(spec.location, resourceGroup().id, deployment().name)}'
  dependsOn: useVnet ? [
    findAvailableIPs[index]
  ] : []
  params: {
    clusterIdentityName: spec.clusterIdentityName
    location: spec.location
    resourceGroupName: resourceGroupName
    keyVaultName: spec.keyVaultName
    servicePrincipalClientID: servicePrincipalClientID
    workerServicePrincipalClientID: workerServicePrincipalClientID
    hostname: hostname
    locationHostname: spec.fullLocationHostName
    useVnet: useVnet
    loadBalancerSubnetName: loadBalancerSubnetName
    internalLoadBalancerIP: useVnet ? findAvailableIPs[index].outputs.availableIP : ''
    replicationSourceHostname: useVnet ? privateLocationHostNames[spec.sourceLocationIndex] : spec.fullSourceLocationHostName
    certificateName: certificateName
    locationCertificateName: spec.locationCertName
    keyVaultTenantID: keyVaultTenantID
    loginTenantID: loginTenantID
    enableWorker: (length(locationSpecs) > 1)
    CleanOldRefRecords: (locationSpecs[0].location == spec.location) ? CleanOldRefRecords : false
    CleanOldBlobs: CleanOldBlobs
    namespacesToReplicate: namespacesToReplicate
    helmVersion: helmVersion
    mainReplicaCount: mainReplicaCount
    workerReplicaCount: 1
    helmChart: helmChart
    helmName: helmName
    helmNamespace: helmNamespace
    siteNamePrefix: siteNamePrefix
    containerImageRepo: containerImageRepo
    containerImageVersion: containerImageVersion
  }
}]

module configAKS 'ContainerService/configure-aks.bicep' = [for (spec, index) in locationSpecs: {
  name: 'configAKS-${uniqueString(spec.location, resourceGroup().id, deployment().name)}'
  params: {
    location: spec.location
    aksName: '${aksName}-${spec.regionCode}'
    additionalCharts: [ ddcSetup[index].outputs.helmChart ]
    publicIpAddress: publicIPs[index].properties.ipAddress
    azureTenantID: azureTenantID
    useExistingManagedIdentity: useExistingManagedIdentity
    managedIdentityName: '${managedIdentityPrefix}${spec.location}'
    existingManagedIdentitySubId: existingManagedIdentitySubId
    existingManagedIdentityResourceGroupName: existingManagedIdentityResourceGroupName
    enableLocalProvisioner: enableLocalPVProvisioner
    isApp: isApp
  }
}]

// Add A records in private DNS zone.
module ipRecords './network/privateDnsZoneARecord.bicep' = [for (spec, index) in locationSpecs: if (useVnet) {
  name: 'addIpRecords-${uniqueString(spec.location, resourceGroup().id, deployment().name)}'
  dependsOn: [
    configAKS
  ] 
  params: {
    privateDnsZoneName: privateDnsZoneName
    recordName: spec.regionCode
    ipAddress: findAvailableIPs[index].outputs.availableIP
  }
}]
