/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/
param location string = 'eastus'

var keyVaultName = 'test-kv'

// Prerequisites
module prereq 'prereq.test.bicep' = {
  name: 'test-prereqs'
  params: {
    location: location
    keyVaultName: 'test-kv'
  }
}

//Test 0.
module test0 '../main2.bicep' = {
  name: 'test0'
  params: {
    location: location
    keyVaultName: keyVaultName
  }
}

var cassandraDBName = 'test-cassandra-db'

module test1 '../main2.bicep' = {
  name: 'test1'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    cassandraDBName: cassandraDBName
    cassandraDBSecretName: 'cassandra-db-secret'
    locationString: 'East US'
  }
}

var cosmosDBName = 'test-cosmos-db'

module test2 '../main2.bicep' = {
  name: 'test2'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    cosmosDBName: cosmosDBName
    cosmosDBSecretName: 'cosmos-db-secret'
  }
}

var eventHubNamespaceName = 'test-eventhub-namespace'
var eventHubName = 'test-eventhub'
var eventHubAuthorizationRulesName = 'test-eventhub-authorizationrules'

module test3 '../main2.bicep' = {
  name: 'test3'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    eventHubNamespaceName: eventHubNamespaceName
    eventHubName: eventHubName
    eventHubAuthorizationRulesName: eventHubAuthorizationRulesName
    eventHubSecretName: 'event-hub-secret'
  }
}

var storageAccountName = 'test-storage-account'

module test4 '../main2.bicep' = {
  name: 'test4'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    storageAccountName: storageAccountName
    storageSecretName: 'storage-secret'
  }
}

var cognitiveServicesName = 'test-cognitive-services'

module test5 '../main2.bicep' = {
  name: 'test5'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    cognitiveServicesName: cognitiveServicesName
    cognitiveServicesSecretName: 'cognitive-services-secret'
  }
}

var batchAccountName = 'test-batch-account'

module test6 '../main2.bicep' = {
  name: 'test6'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    batchAccountName: batchAccountName
    batchAccountSecretName: 'batch-account-secret'
  }
}

var redisName = 'test-redis'

module test7 '../main2.bicep' = {
  name: 'test7'
  params: {
    location: location
    keyVaultName: prereq.outputs.name,
    redisName: redisName,
    redisSecretName:'redis-secret',

  }
}

var mapsAccountName = 'test-maps-account'

module test8 '../main2.bicep' = {
  name: 'test8'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    mapsAccountName: mapsAccountName
    mapsAccountSecretName: 'maps-account-secret'
  }
}

var opertionalInsightsWorkspace = 'test-operationalinsightworkspace'

module test9 '../main2.bicep' = {
  name: 'test9'
  params: {
    location: location
    keyVaultName: prereq.outputs.name
    opertionalInsightsWorkspaceName: opertionalInsightsWorkspace
    opertionalInsightsWorkspaceSecretName: 'operationalinsightworkspace-secret'
  }
}
