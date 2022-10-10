@description('Enable the syncSecret setting for the CSI Driver')
param enableSync bool = true

@description('Enable the secret rotation setting for the CSI Driver')
param enableRotation bool = true

var helmArgs = [
  'csi-secrets-store-provider-azure.secrets-store-csi-driver.syncSecret.enabled=${enableSync}'
  'csi-secrets-store-provider-azure.secrets-store-csi-driver.enableSecretRotation=${enableRotation}'
]
var helmArgsString = replace(replace(string(helmArgs), '[', ''), ']', '')

var helmRepo = 'csi-secrets-store-provider-azure'
var helmRepoURL = 'https://azure.github.io/secrets-store-csi-driver-provider-azure/charts'
var helmChart = 'csi-secrets-store-provider-azure/csi-secrets-store-provider-azure'
var helmName = 'csi'
var namespace = 'kube-system'

var helmCharts = {
  helmRepo: helmRepo
  helmRepoURL: helmRepoURL
  helmChart: helmChart
  helmName: helmName
  helmNamespace: namespace
  helmValues: helmArgsString
}

output helmChart object = helmCharts
