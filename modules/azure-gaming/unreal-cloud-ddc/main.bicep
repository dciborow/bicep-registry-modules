metadata name = 'Unreal Cloud DDC'
metadata description = 'Unreal Cloud DDC for Unreal Engine game development.'
metadata owner = 'dciborow'

//  Parameters
@description('Deployment Location')
param location string

@description('Secondary Deployment Locations')
param secondaryLocations array = []

@description('New or Existing Kubernetes Resources, none to skip.')
@allowed([ 'new', 'existing', 'none' ])
param newOrExistingKubernetes string = 'new'

@description('Name of Kubernetes Resource')
param aksName string = 'ddc-storage-${take(uniqueString(resourceGroup().id), 6)}'

@description('Number of Kubernetes Nodes')
param agentPoolCount int = 3

@description('Whether to use a local ephemeral Persistent Volume provisioner for the cluster')
param enableLocalPVProvisioner bool = true

// By default, use one less replica than the nodes in the agent pool if local PV provisioning is enabled.
// This allows for the ephemeral volume controller to work properly while creating an extra pod during updates.
// TODO: Make use of all agents even with local PV provisioning.
@description('Number of pod replicas for the main Kubernetes Deployment')
param mainReplicaCount int = enableLocalPVProvisioner ? agentPoolCount - 1 : agentPoolCount

@description('Name of Kubernetes Agent Pool')
param agentPoolName string = 'k8agent'

@description('Virtual Machine Skew for Kubernetes')
param vmSize string = 'Standard_L16s_v2'

@description('Kubernetes version should be supported in all requested regions')
param kubernetesVersion string = '1.24.9'

@description('Whether to create a common vnet for the AKS cluster and related resources. If false, the cluster will create and manage the vnet and subnet internally')
param useVnet bool = false

@description('Prefix to use for virtual network name, will be appended with the region code.')
param vnetNamePrefix string = 'vnet-${uniqueString(resourceGroup().id, aksName, location)}-'

@description('Overall address prefix/range for all vnets')
param vnetOverallAddrPrefix string

@description('Address range for a vnet in a given region')
param vnetRegionAddrRange int

@description('Subnet address range for use by K8S VMs')
param vnetVmSubnetAddrRange int

@description('Name of subnet to use for virtual machines')
param vnetVmSubnetName string = 'vmsubnet'

@description('Name of subnet to use for internal load balancers')
param vnetLoadBalancerSubnetName string = 'lbsubnet'

@description('Name of private DNS zone if useVnet is true')
param privateDnsZoneName string

@description('Hostname of Deployment')
param hostname string = 'deploy1.ddc-storage.gaming.azure.com'

@description('If not empty, use the given existing DNS Zone for DNS entries and use shortHostname instead of hostname.')
param dnsZoneName string = ''

@description('If dnsZoneName is specified, its resource group must specified as well, since it is not expected to be part of the deployment resource group.')
param dnsZoneResourceGroupName string = ''

@description('Short hostname of deployment if dnsZoneName is specified')
param shortHostname string = 'ddc'

@description('Enable to configure certificate. Default: true')
param enableCert bool = true

@description('Unknown, Self, or {IssuerName} for certificate signing')
param certificateIssuer string = 'Self'

@description('Certificate Issuer Provider')
param issuerProvider string = ''

@description('Running this template requires roleAssignment permission on the Resource Group, which require an Owner role. Set this to false to deploy some of the resources')
param assignRole bool = true

@description('Enable Zonal Redunancy for supported regions')
param isZoneRedundant bool = true

@description('Create new or use existing Storage Account.')
@allowed([ 'new', 'existing' ])
param newOrExistingStorageAccount string = 'new'

@description('Name of Storage Account resource')
param storageAccountName string = 'ddc${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('Name of Storage Account Resource Group')
param storageResourceGroupName string = resourceGroup().name

@description('Create new or use existing Key Vault')
@allowed([ 'new', 'existing' ])
param newOrExistingKeyVault string = 'new'

@description('Name of Key Vault resource')
param keyVaultName string = take('kv-${uniqueString(resourceGroup().id, subscription().subscriptionId, location)}', 24)

@description('Create new or use existing Public IP resource')
@allowed([ 'new', 'existing' ])
param newOrExistingPublicIp string = 'new'

@description('Name of Public IP Resource, will be suffixed with the location.')
param publicIpName string = 'ddcPublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('Create new or use existing Traffic Manager Profile.')
@allowed([ 'new', 'existing' ])
param newOrExistingTrafficManager string = 'new'

@description('New or existing Traffic Manager Profile.')
param trafficManagerName string = 'traffic-mp-${uniqueString(resourceGroup().id)}'
@description('Relative DNS name for the traffic manager profile, must be globally unique.')
param trafficManagerDnsName string = 'tmp-${uniqueString(resourceGroup().id, subscription().id)}'

@description('Create new or use existing CosmosDB for Cassandra.')
@allowed([ 'new', 'existing' ])
param newOrExistingCosmosDB string = 'new'

@description('Name of Cosmos DB resource.')
param cosmosDBName string = 'ddc-db-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('Name of Cosmos DB Resource Group.')
param cosmosDBRG string = resourceGroup().name

@description('Application Managed Identity ID')
param servicePrincipalClientID string = ''

@description('Worker Managed Identity ID, required for geo-replication.')
param workerServicePrincipalClientID string = ''

@description('Worker Managed Identity Secret, which will be stored in Key Vault, and is required for geo-replication.')
@secure()
param workerServicePrincipalSecret string = ''

@description('Name of Certificate (Default certificate is self-signed)')
param certificateName string = 'unreal-cloud-ddc-cert'

@description('Set to true to agree to the terms and conditions of the Epic Games EULA found here: https://store.epicgames.com/en-US/eula')
param epicEULA bool = false

@description('Active Directory Tennat ID')
param azureTenantID string = subscription().tenantId

@description('Tenant ID for Key Vault')
param keyVaultTenantID string = azureTenantID

@description('Tenant ID for Authentication')
param loginTenantID string = azureTenantID

@description('Delete old ref records no longer in use across the entire system')
param CleanOldRefRecords bool = true

@description('Delete old blobs that are no longer referenced by any ref - this runs in each region to cleanup that regions blob stores')
param CleanOldBlobs bool = true

@secure()
@description('Connection String of User Provided Cassandra Database')
param cassandraConnectionString string = ''

@description('Connection Strings of User Provided Storage Accounts')
param storageConnectionStrings array = []

@description('Reference to the container registry repo with the cloud DDC container image')
param containerImageRepo string

@description('The cloud DDC container image version to use')
param containerImageVersion string = '0.39.2'

@description('Reference to the container registry repo with the cloud DDC helm chart')
param helmChart string

@description('Helm Chart Version')
param helmVersion string

@description('Name of the Helm release')
param helmName string = 'myhordetest'

@description('Namespace of the Helm release')
param helmNamespace string = 'horde-tests'

@description('This is prefixed to each location when naming the site for the location')
param siteNamePrefix string = 'ddc-'

@description('Prefix of Managed Identity used during deployment')
param managedIdentityPrefix string = 'id-ddc-storage-'

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('Set to false to deploy from as an ARM template for debugging')
param isApp bool = true

@description('Set tags to apply to Key Vault resources')
param keyVaultTags object = {}

@description('Array of ddc namespaces to replicate if there are secondary regions')
param namespacesToReplicate array = []

@description('If new or existing, this will enable container insights on the AKS cluster. If new, will create one log analytics workspace per location')
@allowed(['new', 'existing', 'none'])
param newOrExistingWorkspaceForContainerInsights string = 'none'

@description('The name of the log analytics workspace to use for container insights')
param logAnalyticsWorkspaceName string = 'law-ddc-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('The resource group corresponding to an existing logAnalyticsWorkspaceName')
param existingLogAnalyticsWorkspaceResourceGroupName string = ''

@description('Seperator to use for regional DNS URLs. By default, subdomains will be created for each region.')
param locationSpecSeperator string = '.'

var nodeLabels = 'horde-storage'

var useDnsZone = (dnsZoneName != '') && (dnsZoneResourceGroupName != '')
var fullHostname =  useDnsZone ? '${shortHostname}.${dnsZoneName}' : hostname

var newOrExisting = {
  new: 'new'
  existing: 'existing'
}

// When we need a short string for the region.
// Keys correspond to the "locationMapping" object in ddc-umbrella.bicep
var regionCodes = {
  eastus: 'eus'
  eastus2: 'eus2'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
  centralus: 'cus'
  northcentralus: 'ncus'
  southcentralus: 'scus'
  northeurope: 'neu'
  westeurope: 'weu'
  southeastasia: 'seas'
  eastasia: 'eas'
  japaneast: 'jpe'
  japanwest: 'jpw'
  australiaeast: 'aue'
  australiasoutheast: 'ause'
  brazilsouth: 'brs'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralindia: 'cin'
  southafricanorth: 'san'
  uaenorth: 'uaen'
  koreacentral: 'krc'
  chinanorth3: 'cnn3'
}

var enableKubernetes = (newOrExistingKubernetes != 'none')
var newOrExistingPublicIpEffective = enableKubernetes ? newOrExistingPublicIp : 'none'

//  Resources
resource partnercenter 'Microsoft.Resources/deployments@2021-04-01' = {
  name: 'pid-7837dd60-4ba8-419a-a26f-237bbe170773-partnercenter'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

var enableTrafficManager = enableKubernetes && (newOrExistingTrafficManager != 'none')

// Traffic Manager Profile

module trafficManager 'modules/network/trafficManagerProfiles.bicep' = if (enableTrafficManager) {
  name: 'trafficManager-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    name: trafficManagerName
    newOrExisting: newOrExistingTrafficManager
    trafficManagerDnsName: trafficManagerDnsName
  }
}

var trafficManagerNameForEndpoints = enableTrafficManager ? trafficManager.outputs.name : ''

var enableContainerInsights = (newOrExistingWorkspaceForContainerInsights != 'none') && enableKubernetes

// Log Analytics Workspace

module logAnalytics 'modules/insights/logAnalytics.bicep' = if (enableContainerInsights) {
  name: 'logAnalytics-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    newOrExistingWorkspace: newOrExisting[newOrExistingWorkspaceForContainerInsights]
    existingLogAnalyticsWorkspaceResourceGroupName: existingLogAnalyticsWorkspaceResourceGroupName
  }
}

var logAnalyticsWorkspaceResourceId = enableContainerInsights ? logAnalytics.outputs.workspaceId : ''

var allLocations = concat([location], secondaryLocations)

var vnetSpecs = [for (location, index) in allLocations: {
  name: '${vnetNamePrefix}${regionCodes[location]}'
  location: location
}]

module vnets 'modules/network/vnets.bicep' = if (useVnet) {
  name: '${vnetNamePrefix}-eachregion'
  params: {
    vnetSpecs: vnetSpecs
    overallAddrPrefix: vnetOverallAddrPrefix
    regionAddrRange: vnetRegionAddrRange
    vmSubnetName: vnetVmSubnetName
    subnetAddrRange: vnetVmSubnetAddrRange
    loadBalancerSubnetName: vnetLoadBalancerSubnetName
    privateDnsZoneName: privateDnsZoneName
  }
}

var vmSubnetIds = useVnet ? vnets.outputs.vmSubnetIds : []

// Compute "source" location indices for replication.
// Forms a cycle so that a given region replaces from only one other location.
var lastLocationIndex = length(allLocations) - 1
var sourceLocationIndices = [for index in range(0, length(allLocations)): (index > 0) ? index-1 : lastLocationIndex]
var sourceLocations = [for index in sourceLocationIndices: allLocations[index]]

// Prepare a number of properties for each location
var locationSpecs = [for (location, index) in allLocations: {
  location: location
  sourceLocationIndex: sourceLocationIndices[index]
  locationCertName: '${certificateName}-${location}'
  fullLocationHostName: '${regionCodes[location]}${locationSpecSeperator}${fullHostname}'
  fullSourceLocationHostName: '${regionCodes[sourceLocations[index]]}${locationSpecSeperator}${fullHostname}'
  keyVaultName: take('${regionCodes[location]}-${keyVaultName}', 24)
  regionCode: regionCodes[location]
  clusterIdentityName: 'id-${aksName}-${location}'
  vnetName: useVnet ? vnetSpecs[index].name : ''
}]

module allRegionalResources 'modules/resources.bicep' = [for (location, index) in allLocations: if (epicEULA) {
  name: guid(keyVaultName, publicIpName, cosmosDBName, storageAccountName, location)
  dependsOn: enableTrafficManager ? [
    trafficManager
  ] : []
  params: {
    location: location
    regionCode: regionCodes[location]
    newOrExistingKubernetes: newOrExistingKubernetes
    newOrExistingKeyVault: newOrExistingKeyVault
    newOrExistingPublicIp: newOrExistingPublicIpEffective
    newOrExistingStorageAccount: newOrExistingStorageAccount
    vmSubnetId: useVnet ? vmSubnetIds[index] : ''
    kubernetesParams: {
      name: '${aksName}-${locationSpecs[index].regionCode}'
      agentPoolCount: agentPoolCount
      agentPoolName: agentPoolName
      vmSize: vmSize
      version: kubernetesVersion
      clusterIdentityName: locationSpecs[index].clusterIdentityName
      nodeLabels: nodeLabels
    }
    keyVaultName: locationSpecs[index].keyVaultName
    keyVaultTags: keyVaultTags
    publicIpName: '${publicIpName}-${location}'
    trafficManagerNameForEndpoints: trafficManagerNameForEndpoints
    storageAccountName: '${locationSpecs[index].regionCode}${storageAccountName}'
    storageResourceGroupName: storageResourceGroupName
    storageSecretName: 'ddc-storage-connection-string'
    assignRole: assignRole
    isZoneRedundant: isZoneRedundant
    subject: 'system:serviceaccount:${helmNamespace}:workload-identity-sa'
    storageAccountSecret: newOrExistingStorageAccount == 'existing' ? storageConnectionStrings[index] : ''
    useDnsZone: useDnsZone
    dnsZoneName: dnsZoneName
    dnsZoneResourceGroupName: dnsZoneResourceGroupName
    dnsRecordNameSuffix: shortHostname
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    }
}]

module kvCert 'modules/create-kv-certificate/main.bicep' = [for spec in locationSpecs: if (assignRole && enableCert && enableKubernetes) {
  name: 'akvCert-${spec.location}'
  dependsOn: [
    allRegionalResources
  ]
  params: {
    akvName: spec.keyVaultName
    location: spec.location
    certificateNames: [certificateName, spec.locationCertName]
    certificateCommonNames: [fullHostname, spec.fullLocationHostName]
    issuerName: certificateIssuer
    issuerProvider: issuerProvider
    useExistingManagedIdentity: useExistingManagedIdentity
    managedIdentityName: '${managedIdentityPrefix}${spec.location}'
    rbacRolesNeededOnKV: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // Key Vault Admin
    isCrossTenant: isApp
    reuseKey: false
  }
}]

module buildApp 'modules/keyvault/vaults/secrets.bicep' = [for (location, index) in allLocations: if (assignRole && epicEULA && workerServicePrincipalSecret != '') {
  name: 'build-app-${location}-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
  dependsOn: [
    allRegionalResources
  ]
  params: {
    keyVaultName: locationSpecs[index].keyVaultName
    secrets: [{ secretName: 'build-app-secret', secretValue: workerServicePrincipalSecret }]
  }
}]

module cosmosDB 'modules/documentDB/databaseAccounts.bicep' = if(newOrExistingCosmosDB == 'new') {
  name: 'cosmosDB-${uniqueString(location, resourceGroup().id, deployment().name)}-key'
  dependsOn: [
    allRegionalResources
  ]
  params: {
    location: location
    secondaryLocations: secondaryLocations
    name: cosmosDBName
    newOrExisting: newOrExistingCosmosDB
    cosmosDBRG: cosmosDBRG
  }
}

module cassandraKeys 'modules/keyvault/vaults/secrets.bicep' = [for spec in locationSpecs: if (assignRole && epicEULA) {
  name: 'cassandra-keys-${spec.location}-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
  dependsOn: [
    cosmosDB
  ]
  params: {
    keyVaultName: spec.keyVaultName
    secrets: [{ secretName: 'ddc-db-connection-string', secretValue: newOrExistingCosmosDB == 'new' ? cosmosDB.outputs.cassandraConnectionString : cassandraConnectionString }]
  }
}]

module setuplocations 'modules/ddc-setup-locations.bicep' = if (enableKubernetes && assignRole && epicEULA) {
  name: 'setup-ddc-${location}'
  dependsOn: [
    cassandraKeys
    kvCert
  ]
  params: {
    aksName: aksName
    locationSpecs: locationSpecs
    resourceGroupName: resourceGroup().name
    publicIpNamePrefix: publicIpName
    useVnet: useVnet
    servicePrincipalClientID: servicePrincipalClientID
    workerServicePrincipalClientID: workerServicePrincipalClientID
    hostname: fullHostname
    certificateName: certificateName
    azureTenantID: azureTenantID
    keyVaultTenantID: keyVaultTenantID
    loginTenantID: loginTenantID
    CleanOldRefRecords: CleanOldRefRecords
    CleanOldBlobs: CleanOldBlobs
    helmVersion: helmVersion
    helmChart: helmChart
    helmName: helmName
    helmNamespace: helmNamespace
    siteNamePrefix: siteNamePrefix
    containerImageRepo: containerImageRepo
    containerImageVersion: containerImageVersion
    useExistingManagedIdentity: enableCert  // If created, Reuse ID from Cert
    managedIdentityPrefix: managedIdentityPrefix
    existingManagedIdentitySubId: existingManagedIdentitySubId
    existingManagedIdentityResourceGroupName: existingManagedIdentityResourceGroupName
    isApp: isApp
    namespacesToReplicate: namespacesToReplicate
    enableLocalPVProvisioner: enableLocalPVProvisioner
    mainReplicaCount: mainReplicaCount
    privateDnsZoneName: privateDnsZoneName
    loadBalancerSubnetName: vnetLoadBalancerSubnetName
  }
}

var trafficManagerFqdn = enableTrafficManager ? trafficManager.outputs.fqdn : ''

// Add CNAME record for traffic manager only after all regional resources are created
module dnsRecords 'modules/network/dnsZoneCnameRecord.bicep' = if(useDnsZone && enableTrafficManager) {
  name: 'dns-${uniqueString(dnsZoneName, resourceGroup().id, deployment().name)}'
  scope: resourceGroup(dnsZoneResourceGroupName)
  dependsOn: enableTrafficManager ? [
    trafficManager
    allRegionalResources
  ] : [
    allRegionalResources
  ]
  params: {
    dnsZoneName: dnsZoneName
    recordName: shortHostname
    targetFQDN: trafficManagerFqdn
  }
}

// End

@description('Name of Cosmos DB resource')
output cosmosDBName string = cosmosDBName

@description('New or Existing Cosmos DB resource')
output newOrExistingCosmosDB string = newOrExistingCosmosDB
