resource webAppName_webAppName_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  parent: webAppName_resource
  tags: tags
  name: '${webAppName}.azurewebsites.net'
  location: location
  properties: {
    siteName: webAppName
    hostNameType: 'Verified'
  }
}
