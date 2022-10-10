param configuration object
param create_deployment bool = false
// param attach_datastore bool = false
// param create_endpoint bool = false

module createDeployment '../commands/create.bicep'    = if(create_deployment) {
  name: 'createRecomender'
  params: {
    config: configuration
  }
}
// module attachDatastore '../commands/create.bicep'     = if(attach_datastore) {
//   name: 'attachDatastore'
//   params: {
//     config: configuration
//   }
// }

// module createEndpoint '../commands/endpoint.bicep'     = if(create_endpoint) {
//   name: 'createEndpoint'
//   params: {
//     config: configuration
//   }
// }
