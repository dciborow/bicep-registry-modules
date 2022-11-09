param aksName string = ''
param location string
param resourceGroupName string
param keyVaultName string
param servicePrincipalClientID string
param workerServicePrincipalClientID string = servicePrincipalClientID
param hostname string = 'deploy1.horde-storage.gaming.azure.com'
param keyVaultTenantID string = subscription().tenantId
param loginTenantID string = subscription().tenantId
param enableWorker bool = false
param namespace string = ''

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
var namespace = 'horde-tests'
var siteName = 'hordegamingstore'

var imageVersion = '0.36.1'

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
  'horde-storage': {
    config: {
      Azure: { ConnectionString: 'akv!${keyVaultName}|horde-storage-connection-string' }
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
  'horde-storage.worker.env[0].name=AZURE_CLIENT_ID'
  'horde-storage.worker.env[0].value=${federatedId}'
  'horde-storage.worker.env[1].name=AZURE_TENANT_ID'
  'horde-storage.worker.env[1].value=${keyVaultTenantID}'
  'horde-storage.worker.env[2].name=AZURE_FEDERATED_TOKEN_FILE'
  'horde-storage.worker.env[2].value=/var/run/secrets/tokens/azure-identity-token'
  'horde-storage.worker.Replication.Enabled=true'
  'horde-storage.worker.Replication[0].name=ReplicatorName'
  'horde-storage.worker.Replication[0].value=Replicator${location}'
  'horde-storage.worker.Replication[0].name=Namespace'
  'horde-storage.worker.Replication[0].value=${namespace}'
  'horde-storage.worker.Replication[0].name=ConnectionString'
  'horde-storage.worker.Replication[0].value=${helmJSON['horde-storage'].ingress.hostname}'
]

var helmArgs = union([
  'horde-storage.env[0].name=AZURE_CLIENT_ID'
  'horde-storage.env[0].value=${federatedId}'
  'horde-storage.env[1].name=AZURE_TENANT_ID'
  'horde-storage.env[1].value=${keyVaultTenantID}'
  'horde-storage.env[2].name=AZURE_FEDERATED_TOKEN_FILE'
  'horde-storage.env[2].value=/var/run/secrets/tokens/azure-identity-token'
  'horde-storage.service.extraPort[0].name=internal-http'
  'horde-storage.service.extraPort[0].port=8080'
  'horde-storage.service.extraPort[0].targetPort=internal-http'
  'horde-storage.config.Azure.ConnectionString=${helmJSON['horde-storage'].config.Azure.ConnectionString}'
  'horde-storage.config.Scylla.ConnectionString=${helmJSON['horde-storage'].config.Scylla.ConnectionString}'
  'horde-storage.config.Scylla.LocalDatacenterName=${helmJSON['horde-storage'].config.Scylla.LocalDatacenterName}'
  'horde-storage.config.Scylla.LocalKeyspaceSuffix=${helmJSON['horde-storage'].config.Scylla.LocalKeyspaceSuffix}'
  'horde-storage.ingress.hostname=${helmJSON['horde-storage'].ingress.hostname}'
  'horde-storage.ingress.tlsCertName=${helmJSON['horde-storage'].ingress.tlsCertName}'
  'horde-storage.secretStore.clientID=${helmJSON['horde-storage'].secretStore.clientID}'
  'horde-storage.secretStore.keyvaultName=${helmJSON['horde-storage'].secretStore.keyVaultName}'
  'horde-storage.secretStore.resourceGroup=${helmJSON['horde-storage'].secretStore.resourceGroup}'
  'horde-storage.secretStore.subscriptionId=${helmJSON['horde-storage'].secretStore.subscriptionID}'
  'horde-storage.secretStore.tenantId=${helmJSON['horde-storage'].secretStore.tenantID}'
  'horde-storage.serviceAccount.annotations.azure\\.workload\\.identity/client-id=${helmJSON['horde-storage'].serviceAccount.annotations.azure.workload['identity/client-id']}'
  'global.ServiceCredentials.OAuthClientId=${helmJSON.global.ServiceCredentials.OAuthClientId}'
  'global.ServiceCredentials.OAuthClientSecret=${helmJSON.global.ServiceCredentials.OAuthClientSecret}'
  'global.ServiceCredentials.OAuthLoginUrl=${helmJSON.global.ServiceCredentials.OAuthLoginUrl}'
  'global.ServiceCredentials.OAuthScope=${helmJSON.global.ServiceCredentials.OAuthScope}'
  'global.auth.schemes.Bearer.jwtAuthority=${helmJSON.global.jwtAuthority}'
  'global.auth.schemes.Bearer.jwtAudience=${helmJSON.global.jwtAudience}'
  'horde-storage.podForceRestart=true'
], enableWorker ? helmWorker : false)

var helmArgsString = substring(string(helmArgs), 1, length(string(helmArgs)) - 2)

var helmCharts = {
  helmChart: helmChart
  helmName: helmName
  helmNamespace: namespace
  helmValues: helmArgsString
  helmWorker: helmWorker
}

output helmChart object = helmCharts
