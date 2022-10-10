param webAppName string
param webAppAuthAppId string

resource weppApp 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${webAppName}/authsettings'
  properties: {
    enabled: true
    unauthenticatedClientAction: 'RedirectToLoginPage'
    tokenStoreEnabled: true
    defaultProvider: 'AzureActiveDirectory'
    clientId: webAppAuthAppId
    tokenRefreshExtensionHours: 1
    allowedAudiences: [
      'https://${webAppName}.azurewebsites.net'
    ]
    issuer: 'https://sts.windows.net/${subscription().tenantId}/'
  }
}
output id string = weppApp.id
