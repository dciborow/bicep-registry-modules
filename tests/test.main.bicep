param location string = 'eastus'

module test1 '../app_contents/mainTemplate.bicep' = {
  name: 'Test1'
  params: {
    location: location
    _artifactsLocation: 'https://dciborowmmlsparkstore.blob.core.windows.net/mmlspark/'
    _artifactsLocationSasToken: ''
    agentPoolCount: 3
    agentPoolName: 'k8agent'
    servicePrincipalObjectID: '9427e5fe-13f8-475b-aeca-945561bd91bd'
    servicePrincipalClientID: '799926db-87bf-44e2-9eac-66fb84915841'
    hostname: 'deploy1.horde-storage.gaming.azure.com'
    certificateIssuer: 'Azure-Gaming'
    issuerProvider: 'OneCertV2-PublicCA'
    isZoneRedundant: false
    epicEULA: true
    newOrExistingCosmosDB: 'existing'
    cosmosDBName: 'devops-uc-ddc'
    cosmosDBRG: 'dciborow-fast-devops'
  }
}
