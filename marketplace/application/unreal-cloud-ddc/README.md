# Overview - Unreal Cloud DDC on Azure

```yml
app_id: azure-uc-ddc
app_name: Unreal Cloud DDC on Azure
plan_names:
  - horde-storage: 
    type: managed_app

listing_config: ./listing_config.json
app_contents: ./app_contents
```

# Deployment 
## Prereqs
Before deploying the Unreal Cloud DDC solution, the following is needed:
* Service Principal, the object_id (not the app_id) will be provided as the input to the creation script, `OBJECT_ID`.
  * `az ad sp create-for-rbac`
* Create `main.parameters.json` with values for deployment. `app_contents/mainTemplate.parameters.json` may be used as an example.

## Deply Unreal Cloud DDC
Create a new shell script using `../scripts/horde-deploy.sh` as an example or run:
 
```bash
MY_CLUSTER=<Name of AKS Cluster>
MY_RG=<Name of Resource Group>
MY_MRG=<Name of Mananaged Resource Group>
LOCATION=<Primary Azure Region of Deployment>
AGENT_POOL_COUNT=<Number of AKS Nodes>
OBJECT_ID=<OBJECT_ID of Service Principal>

../scripts/horde-deploy.sh $MY_CLUSTER $RESOURCE_GROUP $LOCATION $AGENT_POOL_COUNT $OBJECT_ID
```

From the output, copy and run the `az rest ...` command to setup the federated credential.

## Setup Unreal Cloud DDC
Ensure that you have run the `az rest ...` command outputted in the last step, and that the federated credential has been succesfully set. Before the Helm charts are installed, the following setup is required:

* Add the Service Principal as a Secrets Admin to Key Vault
* Set the following Secrets to Key Vault to the SP Secret
  * horde-client-app-secret
  * build-app-secret

Now restart the "horde-test" containers on the AKS cluster.

Once succesfully deployed, you should be able to validate by visting `https://CLUSTER_URL/health/live`
# Code structure

|Directory|Description|
|------------|----------|
|[`app_contents/`](app_contents)|Deployment template files for the Application.|


# Testing

Post deployment tests have been created in Python. To use, first install "microsoft-industrialai" utilities from "src". Then run using "pytest tests". 