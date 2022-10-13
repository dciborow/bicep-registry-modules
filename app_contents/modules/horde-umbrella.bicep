param location string
param resourceGroupName string
param keyVaultName string
param servicePrincipalClientID string
param hostname string = 'deploy1.horde-storage.gaming.azure.com'

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

var tenantID = tenant().tenantId

var helmChart = 'oci://tchordestoragecontainerregistry.azurecr.io/helm/tc-horde-storage'
var helmName = 'myhordetest'
var namespace = 'horde-tests'
var siteName = 'hordegamingstore'

var imageVersion = '0.36.1'

var secretStore = {
  enabled: true
  clientID: servicePrincipalClientID
  keyVaultName: keyVaultName
  resourceGroup: resourceGroupName
  subscriptionID: subscription().subscriptionId
  tenantID: tenantID
}

var aadAuth = {
  tenantID: tenantID
  clientID: servicePrincipalClientID
  clientSecret: 'horde-client-app-secret'
  keyVaultName: keyVaultName
  groupClientCacheRefreshIntervalHours: '1.0'
  rolesCacheRefreshIntervalHours: '1.0'
}

var loginDomain = 'microsoftonline'

var global = {
  siteName: siteName
  authMethod: 'JWTBearer'
  jwtAuthority: 'https://login.${loginDomain}.com/${tenantID}'
  jwtAudience: 'api://${servicePrincipalClientID}'
  OverrideAppVersion: imageVersion
  ServiceCredentials: {
    OAuthClientId: servicePrincipalClientID
    OAuthClientSecret: 'akv!${keyVaultName}|build-app-secret'
    OAuthLoginUrl: '${environment().authentication.loginEndpoint}${tenantID}/oauth2/v2.0/token'
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
  tlsCertName: 'horde-storage-cert'
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
      annotations: { azure: { workload: { 'identity/client-id': servicePrincipalClientID } } }
    }
  }
  global: global
}

var helmArgs = [
  'horde-storage.podForceRestart=true'
  'x-jupiter-env.env[0].name=DD_AGENT_HOST'
  'x-jupiter-env.env[0].valueFrom.fieldRef.fieldPath=status.hostIP'
  'x-jupiter-env.env[1].DD_ENV=dev'
  'x-jupiter-env.env[2].DD_SERVICE="{{ .Chart.Name }}"'
  'x-jupiter-env.env[3].ASPNETCORE_URLS="http://0.0.0.0:80;http://0.0.0.0:8080"'
  'x-jupiter-env.env[4].AZURE_CLIENT_ID=${servicePrincipalClientID}'
  'x-jupiter-env.env[5].AZURE_TENANT_ID=${tenantID}'
  'x-jupiter-env.env[6].AZURE_FEDERATED_TOKEN_FILE=/var/run/secrets/tokens/azure-identity-token'
  'horde-storage.config.Azure.ConnectionString=${helmJSON['horde-storage'].config.Azure.ConnectionString}'
  'horde-storage.config.Scylla.ConnectionString=${helmJSON['horde-storage'].config.Scylla.ConnectionString}'
  'horde-storage.config.Scylla.LocalDatacenterName=${helmJSON['horde-storage'].config.Scylla.LocalDatacenterName}'
  'horde-storage.config.Scylla.LocalKeyspaceSuffix=${helmJSON['horde-storage'].config.Scylla.LocalKeyspaceSuffix}'
  'horde-storage.config.Scylla.UseAzureCosmosDB=${helmJSON['horde-storage'].config.Scylla.UseAzureCosmosDB}'
  'horde-storage.config.Scylla.InlineBlobMaxSize=${helmJSON['horde-storage'].config.Scylla.InlineBlobMaxSize}'
  'horde-storage.ingress.hostname=${helmJSON['horde-storage'].ingress.hostname}'
  'horde-storage.ingress.tlsSecretName=${helmJSON['horde-storage'].ingress.tlsSecretName}'
  'horde-storage.ingress.tlsCertName=${helmJSON['horde-storage'].ingress.tlsCertName}'
  'horde-storage.persistence.enabled=false'  
  'horde-storage.secretStore.enabled=${helmJSON['horde-storage'].secretStore.enabled}'
  'horde-storage.secretStore.clientID=${helmJSON['horde-storage'].secretStore.clientID}'
  'horde-storage.secretStore.keyvaultName=${helmJSON['horde-storage'].secretStore.keyVaultName}'
  'horde-storage.secretStore.resourceGroup=${helmJSON['horde-storage'].secretStore.resourceGroup}'
  'horde-storage.secretStore.subscriptionID=${helmJSON['horde-storage'].secretStore.subscriptionID}'
  'horde-storage.secretStore.tenantID=${helmJSON['horde-storage'].secretStore.tenantID}'
  'horde-storage.serviceAccount.name=${helmJSON['horde-storage'].serviceAccount.name}'
  'horde-storage.serviceAccount.annotations.azure\\.workload\\.identity/client-id=${helmJSON['horde-storage'].serviceAccount.annotations.azure.workload['identity/client-id']}'
  'horde-storage.worker.env[0].name=DD_AGENT_HOST'
  'horde-storage.worker.env[0].valueFrom.fieldRef.fieldPath=status.hostIP'
  'horde-storage.worker.env[1].DD_ENV=dev'
  'horde-storage.worker.env[2].DD_SERVICE="{{ .Chart.Name }}"'
  'horde-storage.worker.env[3].DD_VERSION="{{ .Values.global.OverrideAppVersion }}"'
  'horde-storage.worker.env[4].ASPNETCORE_URLS="http://0.0.0.0:80;http://0.0.0.0:8080"'
  'horde-storage.worker.env[5].AZURE_CLIENT_ID=${servicePrincipalClientID}'
  'horde-storage.worker.env[6].AZURE_TENANT_ID=${tenantID}'
  'horde-storage.worker.env[7].AZURE_FEDERATED_TOKEN_FILE=/var/run/secrets/tokens/azure-identity-token'
  'global.siteName=${helmJSON.global.siteName}'
  'global.authMethod=${helmJSON.global.authMethod}'
  'global.jwtAuthority="${helmJSON.global.jwtAuthority}"'
  'global.jwtAudience="${helmJSON.global.jwtAudience}"'
  'global.OverrideAppVersion=${helmJSON.global.OverrideAppVersion}'
  'global.ServiceCredentials.OAuthClientId=${helmJSON.global.ServiceCredentials.OAuthClientId}'
  'global.ServiceCredentials.OAuthClientSecret=${helmJSON.global.ServiceCredentials.OAuthClientSecret}'
  'global.ServiceCredentials.OAuthLoginUrl=${helmJSON.global.ServiceCredentials.OAuthLoginUrl}'
  'global.ServiceCredentials.OAuthScope=${helmJSON.global.ServiceCredentials.OAuthScope}'
  'global.TheCoalition.TCAuth.GroupClient.TenantId=${aadAuth.tenantID}'
  'global.TheCoalition.TCAuth.GroupClient.ClientId=${aadAuth.clientID}'
  'global.TheCoalition.TCAuth.GroupClient.ClientSecretName=${aadAuth.clientSecret}'
  'global.TheCoalition.TCAuth.GroupClient.KeyVaultName=${aadAuth.keyVaultName}'
  'global.TheCoalition.TCAuth.GroupClient.CacheRefreshIntervalHours=${aadAuth.groupClientCacheRefreshIntervalHours}'
  'global.TheCoalition.TCAuth.Roles.CacheRefreshIntervalHours=${aadAuth.rolesCacheRefreshIntervalHours}'
]

var helmArgsString = substring(string(helmArgs), 1, length(string(helmArgs)) - 2)

var helmCharts = {
  helmChart: helmChart
  helmName: helmName
  helmNamespace: namespace
  helmValues: helmArgsString
}

output helmChart object = helmCharts
