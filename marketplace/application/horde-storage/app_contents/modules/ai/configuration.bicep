param location              string = resourceGroup().location

param enableAppInsights       bool = false
param enableStorage           bool = false
param enableVNet              bool = false
param enableKeyVault          bool = false
param enableSearch            bool = false
param enableML                bool = false
param enableMLCompute         bool = false
param enableDatabricks        bool = false
param enableCosmosDB          bool = false
param enableCogService        bool = false
param enabledbvnet            bool = false
param enableMLAKS             bool = false
param enableaksvnet           bool = false
param enableWebsite           bool = false
param enablePSQL              bool = false
param enableServerFarm        bool = false
param enableContainerReg      bool = false
param enableDataFactory       bool = false

param appInsightsName       string = 'appinsights${uniqueString(resourceGroup().id)}'
param storageAccountName    string = 'subnet${uniqueString(resourceGroup().id)}'
param subnetName            string = 'storage${uniqueString(resourceGroup().id)}'
param vNetName              string = 'vn-${uniqueString(resourceGroup().id)}'
param searchName            string = 'search${uniqueString(resourceGroup().id)}'
param keyVault              string = 'keyVault-${uniqueString(resourceGroup().id)}'
param mlWorkspace           string = 'ml-${uniqueString(resourceGroup().id)}'
param mlCompute             string = 'mlcompute${uniqueString(resourceGroup().id)}'
param mlDatastore           string = 'mldatastore${uniqueString(resourceGroup().id)}'
param databricks            string = 'db${uniqueString(resourceGroup().id)}'
param cogService            string = 'cogService${uniqueString(resourceGroup().id)}'
param cogServiceSubnet      string = 'cogServiceSubnet${uniqueString(resourceGroup().id)}'
param cosmosDB              string = 'cosmosDB${uniqueString(resourceGroup().id)}'
param aksName               string = 'aks${uniqueString(resourceGroup().id)}'
param website               string = 'website${uniqueString(resourceGroup().id)}'
param psql                  string = 'psql${uniqueString(resourceGroup().id)}'
param serverFarm            string = 'serverFarm${uniqueString(resourceGroup().id)}'
param containerReg          string = 'dataRegistry${uniqueString(resourceGroup().id)}'
param dataFactory           string = 'dataFactory${uniqueString(resourceGroup().id)}'

param tags                  object = {
                                        'aia-industry':         'industry'
                                        'aia-solution':         'solution'
                                        'aia-version':          '0.0'
                                      }

param searchSettings        object = {
                                        'searchSku':            'storage_optimized_l1'
                                        'partitionCount':       1
                                        'replicaCount':         1
                                      }


var enable = {
  'vNET':                 enableVNet
  'keyVault':             enableKeyVault
  'appInsights':          enableAppInsights
  'search':               enableSearch
  'ml':                   enableML
  'ml_compute':           enableMLCompute
  'storage':              enableStorage
  'databricks':           enableDatabricks
  'cosmosDB':             enableCosmosDB
  'DBVNET':               enabledbvnet
  'mlAKS':                enableMLAKS
  'AKSVNET':              enableaksvnet
  'cogService':           enableCogService
  'website':              enableWebsite
  'pqsl':                 enablePSQL
  'serverFarm':           enableServerFarm
  'dataFactory':          enableDataFactory
  'containerReg':         enableDataRegistry
}

var resources = {
  'appInsightsName':      appInsightsName
  'subnetName':           subnetName
  'storageAccountName':   storageAccountName
  'searchName':           searchName
  'vNetName':             vNetName
  'keyVault':             keyVault
  'mlWorkspace':          mlWorkspace
  'mlCompute':            mlCompute
  'mlDatastore':          mlDatastore
  'databricks':           databricks
  'aksName':              aksName
  'aksSubnet':            'subnet4${aksName}'
  'cogService':           cogService
  'cogServiceSubnet':     cogServiceSubnet
  'cosmosDB':             cosmosDB
  'website':              website
  'psql':                 psql
  'serverFarm':           serverFarm
  'dataFactory':          dataFactory
  'containerReg':         dataRegistry
}

var configuration                   = {
                                      'tags':                   tags      
                                      'location':               location
                                      'uniqueKey':              uniqueString(resourceGroup().id)
                                      vnet: {
                                        name:                   vNetName
                                        enable:                 enableVNet
                                      }
                                      'enable':                 enable
                                      'resources':              resources
                                      'searchSettings':         searchSettings
                                    }

output configuration          object = configuration
