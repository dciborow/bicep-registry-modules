@description('The name of the Azure Key Vault')
param akvName string

@description('The location to deploy the resources to')
param location string

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@description('The RoleDefinitionId required for the DeploymentScript resource to interact with KeyVault')
param rbacRolesNeededOnKV string = 'a4417e6f-fecd-4de8-b567-7b0420556985' //KeyVault Certificate Officer

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('Name of the Managed Identity resource')
param managedIdentityName string = 'id-KeyVaultCertificateCreator-${uniqueString(akvName, location, resourceGroup().name)}'

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('The names of the certificate to create')
param certificateNames array

@description('The common names of the certificate to create')
param certificateCommonNames array = certificateNames

@description('A delay before the script import operation starts. Primarily to allow Azure AAD Role Assignments to propagate')
param initialScriptDelay string = '0'

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

@description('Unknown, Self, or {IssuerName} for certificate signing')
param issuerName string = 'Self'

@description('Certificate Issuer Provider')
param issuerProvider string = ''

@description('Set to false to deploy from as an ARM template for debugging') 
param isApp bool = true

resource akv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: akvName
}

@description('A new managed identity that will be created in this Resource Group, this is the default option')
resource newDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = if (!useExistingManagedIdentity) {
  name: managedIdentityName
  location: location
}

@description('An existing managed identity that could exist in another sub/rg')
resource existingDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if (useExistingManagedIdentity ) {
  name: managedIdentityName
  scope: resourceGroup(existingManagedIdentitySubId, existingManagedIdentityResourceGroupName)
}

@description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

var delegatedManagedIdentityResourceId = useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id

resource rbacKv 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(akv.id, rbacRolesNeededOnKV, string(useExistingManagedIdentity))
  scope: akv
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalId: useExistingManagedIdentity ? existingDepScriptId.properties.principalId : newDepScriptId.properties.principalId
    principalType: 'ServicePrincipal'
    delegatedManagedIdentityResourceId: isApp ? delegatedManagedIdentityResourceId : null
  }
}

resource createImportCerts 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for (certName, index) in certificateNames: {
  name: 'AKV-Cert-${akv.name}-${replace(replace(certName,':',''),'/','-')}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id}': {}
    }
  }
  kind: 'AzureCLI'
  dependsOn: [
    rbacKv
  ]
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.35.0'
    timeout: 'PT10M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'akvName'
        value: akvName
      }
      {
        name: 'certName'
        value: certName
      }
      {
        name: 'certCommonName'
        value: certificateCommonNames[index]
      }
      {
        name: 'initialDelay'
        value: initialScriptDelay
      }
      {
        name: 'issuerName'
        value: issuerName
      }
      {
        name: 'issuerProvider'
        value: issuerProvider
      }
      {
        name: 'retryMax'
        value: '10'
      }
      {
        name: 'retrySleep'
        value: '5s'
      }
    ]
    scriptContent: loadTextContent('create-kv-cert.sh')
    cleanupPreference: cleanupPreference
  }
}]

// Output results from the first certificate.

@description('Certificate name')
output certificateName string = createImportCerts[0].properties.outputs.name

@description('KeyVault secret id to the created version')
output certificateSecretId string = contains(createImportCerts[0].properties.outputs, 'certSecretId') ? createImportCerts[0].properties.outputs.certSecretId.versioned : ''

@description('KeyVault secret id which uses the unversioned uri')
output certificateSecretIdUnversioned string = contains(createImportCerts[0].properties.outputs, 'certSecretId') ? createImportCerts[0].properties.outputs.certSecretId.unversioned : ''

@description('Certificate Thumbprint')
output certificateThumbprint string = contains(createImportCerts[0].properties.outputs, 'thumbprint') ? createImportCerts[0].properties.outputs.thumbprint : ''

@description('Certificate Thumbprint (in hex)')
output certificateThumbprintHex string = contains(createImportCerts[0].properties.outputs, 'thumbprintHex') ? createImportCerts[0].properties.outputs.thumbprintHex : ''
