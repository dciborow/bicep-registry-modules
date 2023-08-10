param aksName string
param location string
param publicIpAddress string = ''
param additionalCharts array = []

param enableWorkloadIdentity bool = true
#disable-next-line secure-secrets-in-params 
param enableSecretStore bool = true
param enableIngress bool = true
param enableLocalProvisioner bool = true
param azureTenantID string = subscription().tenantId

param managedIdentityName string = 'id-ddc-storage-${location}'

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('Set to false to deploy from as an ARM template for debugging') 
param isApp bool = true

module helmInstallWorkloadID 'workload-id.bicep' = if(enableWorkloadIdentity) { 
  name: 'helmInstallWorkloadID-${uniqueString(aksName, location, resourceGroup().name)}'
  params: {
    azureTenantID: azureTenantID
  }
}

module helmInstallSecretStore 'csi-secret-store.bicep' = if(enableSecretStore) { name: 'helmInstallSecretStore-${uniqueString(aksName, location, resourceGroup().name)}' }

module helmInstallIngress 'nginx-ingress.bicep' = if(enableIngress) {
  name: 'helmInstallIngress-${uniqueString(aksName, location, resourceGroup().name)}'
  params: { staticIP: publicIpAddress }
}

module helmInstallLocalProvisioner 'local-pv-provisioner.bicep' = if(enableLocalProvisioner) {
  name: 'helmInstallProvisioner-${uniqueString(aksName, location, resourceGroup().name)}'
}

var helmChartsPreReqs = union(
  enableWorkloadIdentity ? [helmInstallWorkloadID.outputs.helmChart] : [], 
  enableIngress ? [helmInstallIngress.outputs.helmChart] : [],
  enableSecretStore ? [helmInstallSecretStore.outputs.helmChart] : [],
  enableLocalProvisioner ? [helmInstallLocalProvisioner.outputs.helmChart] : []
  )

  module prereqs 'helmChartInstall.bicep' = {
    name: 'helmInstallPrereqs-${uniqueString(aksName, location, resourceGroup().name)}'
    params: {
      aksName: aksName
      location: location
      helmCharts: helmChartsPreReqs
      useExistingManagedIdentity: useExistingManagedIdentity
      managedIdentityName: managedIdentityName
      existingManagedIdentitySubId: existingManagedIdentitySubId
      existingManagedIdentityResourceGroupName: existingManagedIdentityResourceGroupName
      isApp: isApp
    }
  }

// Ingress needs some time to start up. Otherwise the next helm install will fail
module delay '../delay.bicep' = {
  name: 'delay-${uniqueString(aksName, location, resourceGroup().name)}'
  dependsOn: [
    prereqs
  ]
  params: {
    location: location
    sleepName: 'sleep-${uniqueString(aksName, location, resourceGroup().name)}'
    sleepSeconds: 30
  }
}

module combo 'helmChartInstall.bicep' = {
  name: 'helmInstallAdditional-${uniqueString(aksName, location, resourceGroup().name)}'
  dependsOn: [
    delay
  ]
  params: {
    aksName: aksName
    location: location
    helmCharts: additionalCharts
    useExistingManagedIdentity: useExistingManagedIdentity
    managedIdentityName: managedIdentityName
    existingManagedIdentitySubId: existingManagedIdentitySubId
    existingManagedIdentityResourceGroupName: existingManagedIdentityResourceGroupName
    isApp: isApp
  }
}
