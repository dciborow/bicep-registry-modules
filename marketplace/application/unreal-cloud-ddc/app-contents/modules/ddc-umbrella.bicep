param aksName string = ''
param location string
param resourceGroupName string
param keyVaultName string
param servicePrincipalClientID string
param workerServicePrincipalClientID string = servicePrincipalClientID
param hostname string = 'deploy1.ddc-storage.gaming.azure.com'
param keyVaultTenantID string = subscription().tenantId
param loginTenantID string = subscription().tenantId
param enableWorker bool = false
param namespace string = ''

@description('this should be enabled in one region - it will delete old ref records no longer in use across the entire system')
param CleanOldRefRecords bool = false

@description('this will delete old blobs that are no longer referenced by any ref - this runs in each region to cleanup that regions blob stores')
param CleanOldBlobs bool = true

resource clusterUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: 'id-${aksName}-${location}'
}

var federatedId = clusterUser.properties.clientId

var locationMapping = {
  eastus: 'East US'
  eastus2: 'East US 2'
  westus: 'West US'
  westus2: 'West US 2'
  westus3: 'West US 3'
  centralus: 'Central US'
  northcentralus: 'North Central US'
  southcentralus: 'South Central US'
  northeurope: 'North Europe'
  westeurope: 'West Europe'
  southeastasia: 'Southeast Asia'
  eastasia: 'East Asia'
  japaneast: 'Japan East'
  japanwest: 'Japan West'
  australiaeast: 'Australia East'
  australiasoutheast: 'Australia Southeast'
  brazilsouth: 'Brazil South'
  canadacentral: 'Canada Central'
  canadaeast: 'Canada East'
  centralindia: 'Central India'
  southafricanorth: 'South Africa North'
  uaenorth: 'UAE North'
  koreacentral: 'Korea Central'
  chinanorth3: 'China North 3'
}

var helmChart = 'oci://tchordestoragecontainerregistry.azurecr.io/helm/tc-horde-storage'
var helmName = 'myhordetest'
var helmNamespace = 'ddc-tests'
var siteName = 'ddcgamingstore'

var imageVersion = '0.37.4'

var secretStore = {
  enabled: true
  clientID: federatedId
  keyVaultName: keyVaultName
  resourceGroup: resourceGroupName
  subscriptionID: subscription().subscriptionId
  tenantID: keyVaultTenantID
}

var loginDomain = 'microsoftonline'

var global = {
  siteName: siteName
  authMethod: 'JWTBearer'
  jwtAuthority: 'https://login.${loginDomain}.com/${loginTenantID}'
  jwtAudience: 'api://${servicePrincipalClientID}'
  OverrideAppVersion: imageVersion
  ServiceCredentials: {
    OAuthClientId: workerServicePrincipalClientID
    OAuthClientSecret: 'akv!${keyVaultName}|build-app-secret'
    OAuthLoginUrl: '${environment().authentication.loginEndpoint}${loginTenantID}/oauth2/v2.0/token'
    OAuthScope: 'api://${servicePrincipalClientID}/.default'
  }
}

var ingress = {
  enabled: true
  annotations: {
    'kubernetes.io/ingress.class': 'nginx'
    'nginx.ingress.kubernetes.io/proxy-body-size': 0
  }
  hostname: hostname
  path: '/'
  pathType: 'Prefix'
  port: 8080
  tlsSecretName: 'ingress-tls-csi'
  tlsCertName: 'unreal-cloud-ddc-cert'
}

// helm install --set-json '${string(helmJSON)}'
var helmJSON = {
  'unreal-cloud-ddc': {
    config: {
      Azure: { ConnectionString: 'akv!${keyVaultName}|ddc-connection-string' }
      Scylla: {
        ConnectionString: 'akv!${keyVaultName}|horde-db-connection-string'
        LocalDatacenterName: locationMapping[location]
        LocalKeyspaceSuffix: location
        UseAzureCosmosDB: true
        InlineBlobMaxSize: 0
      }
    }
    ingress: ingress
    secretStore: secretStore
    serviceAccount: {
      name: 'workload-identity-sa'
      annotations: { azure: { workload: { 'identity/client-id': federatedId } } }
    }
  }
  global: global
}

var helmWorker = [
  'unreal-cloud-ddc.worker.config.Replication.Enabled=true'
  'unreal-cloud-ddc.worker.config.Replication.Replicators[0].ReplicatorName=Replicator${location}'
  'unreal-cloud-ddc.worker.config.Replication.Replicators[0].Namespace=${namespace}'
  'unreal-cloud-ddc.worker.config.Replication.Replicators[0].Version=Refs'
  'unreal-cloud-ddc.worker.config.Replication.Replicators[0].ConnectionString=${helmJSON['unreal-cloud-ddc'].ingress.hostname}'
]

var helmArgs = union([
  'unreal-cloud-ddc.env[0].name=AZURE_CLIENT_ID'
  'unreal-cloud-ddc.env[0].value=${federatedId}'
  'unreal-cloud-ddc.env[1].name=AZURE_TENANT_ID'
  'unreal-cloud-ddc.env[1].value=${keyVaultTenantID}'
  'unreal-cloud-ddc.env[2].name=AZURE_FEDERATED_TOKEN_FILE'
  'unreal-cloud-ddc.env[2].value=/var/run/secrets/tokens/azure-identity-token'
  'unreal-cloud-ddc.service.extraPort[0].name=internal-http'
  'unreal-cloud-ddc.service.extraPort[0].port=8080'
  'unreal-cloud-ddc.service.extraPort[0].targetPort=internal-http'
  'unreal-cloud-ddc.config.Azure.ConnectionString=${helmJSON['unreal-cloud-ddc'].config.Azure.ConnectionString}'
  'unreal-cloud-ddc.config.Scylla.ConnectionString=${helmJSON['unreal-cloud-ddc'].config.Scylla.ConnectionString}'
  'unreal-cloud-ddc.config.Scylla.LocalDatacenterName=${helmJSON['unreal-cloud-ddc'].config.Scylla.LocalDatacenterName}'
  'unreal-cloud-ddc.config.Scylla.LocalKeyspaceSuffix=${helmJSON['unreal-cloud-ddc'].config.Scylla.LocalKeyspaceSuffix}'
  'unreal-cloud-ddc.config.Scylla.UseAzureCosmosDB=true'
  'unreal-cloud-ddc.config.Scylla.InlineBlobMaxSize=0'
  'unreal-cloud-ddc.ingress.hostname=${helmJSON['unreal-cloud-ddc'].ingress.hostname}'
  'unreal-cloud-ddc.ingress.tlsCertName=${helmJSON['unreal-cloud-ddc'].ingress.tlsCertName}'
  'unreal-cloud-ddc.secretStore.clientID=${helmJSON['unreal-cloud-ddc'].secretStore.clientID}'
  'unreal-cloud-ddc.secretStore.keyvaultName=${helmJSON['unreal-cloud-ddc'].secretStore.keyVaultName}'
  'unreal-cloud-ddc.secretStore.resourceGroup=${helmJSON['unreal-cloud-ddc'].secretStore.resourceGroup}'
  'unreal-cloud-ddc.secretStore.subscriptionId=${helmJSON['unreal-cloud-ddc'].secretStore.subscriptionID}'
  'unreal-cloud-ddc.secretStore.tenantId=${helmJSON['unreal-cloud-ddc'].secretStore.tenantID}'
  'unreal-cloud-ddc.serviceAccount.annotations.azure\\.workload\\.identity/client-id=${helmJSON['unreal-cloud-ddc'].serviceAccount.annotations.azure.workload['identity/client-id']}'
  'unreal-cloud-ddc.worker.env[0].name=AZURE_CLIENT_ID'
  'unreal-cloud-ddc.worker.env[0].value=${federatedId}'
  'unreal-cloud-ddc.worker.env[1].name=AZURE_TENANT_ID'
  'unreal-cloud-ddc.worker.env[1].value=${keyVaultTenantID}'
  'unreal-cloud-ddc.worker.env[2].name=AZURE_FEDERATED_TOKEN_FILE'
  'unreal-cloud-ddc.worker.env[2].value=/var/run/secrets/tokens/azure-identity-token'
  'unreal-cloud-ddc.worker.enabled=true'
  'unreal-cloud-ddc.worker.config.Azure.ConnectionString=${helmJSON['unreal-cloud-ddc'].config.Azure.ConnectionString}'
  'unreal-cloud-ddc.worker.config.Scylla.ConnectionString=${helmJSON['unreal-cloud-ddc'].config.Scylla.ConnectionString}'
  'unreal-cloud-ddc.worker.config.Scylla.LocalDatacenterName=${helmJSON['unreal-cloud-ddc'].config.Scylla.LocalDatacenterName}'
  'unreal-cloud-ddc.worker.config.Scylla.LocalKeyspaceSuffix=${helmJSON['unreal-cloud-ddc'].config.Scylla.LocalKeyspaceSuffix}'
  'unreal-cloud-ddc.worker.config.Scylla.UseAzureCosmosDB=true'
  'unreal-cloud-ddc.worker.config.Scylla.InlineBlobMaxSize=0'
  'unreal-cloud-ddc.worker.config.GC.CleanOldRefRecords=${CleanOldRefRecords}'
  'unreal-cloud-ddc.worker.config.GC.CleanOldBlobs=${CleanOldBlobs}'
  'global.ServiceCredentials.OAuthClientId=${helmJSON.global.ServiceCredentials.OAuthClientId}'
  'global.ServiceCredentials.OAuthClientSecret=${helmJSON.global.ServiceCredentials.OAuthClientSecret}'
  'global.ServiceCredentials.OAuthLoginUrl=${helmJSON.global.ServiceCredentials.OAuthLoginUrl}'
  'global.ServiceCredentials.OAuthScope=${helmJSON.global.ServiceCredentials.OAuthScope}'
  'global.auth.schemes.Bearer.jwtAuthority=${helmJSON.global.jwtAuthority}'
  'global.auth.schemes.Bearer.jwtAudience=${helmJSON.global.jwtAudience}'
  'unreal-cloud-ddc.podForceRestart=true'
], enableWorker ? helmWorker : [])

var helmArgsString = substring(string(helmArgs), 1, length(string(helmArgs)) - 2)

var helmCharts = {
  helmChart: helmChart
  helmName: helmName
  helmNamespace: helmNamespace
  helmValues: helmArgsString
  helmWorker: helmWorker
}

output helmChart object = helmCharts
