# ARM template deployment

## Deploy Azure services

1. You must deploy the template to a subscription backed by the `publisher tenant`
1. Login to the target subscription
1. Edit the script `helpers/deploy-to-rg.sh` and set values for
    * `SUB_ID` - the subscription ID of the **source** KV
    * `RG` - resource group name for this new deployment
    * `DNS_PREFIX` - a DNS prefix for the FQDN eg 'meo'
1. Run the `deploy-to-rg.sh` script to deploy the services

```bash
./helpers/deploy-to-rg.sh
```

1. When the deployment is complete, **capture the outputs**. These will be needed for the next steps
1. The outputs will look something like this

```json
    "outputs": {
      "controlPlaneFQDN": {
        "type": "String",
        "value": "meo-f3e35a46.hcp.westeurope.azmk8s.io"
      },
      "customerManagedResourceGroupName": {
        "type": "String",
        "value": "test-delete-220311-1431"
      },
      "customerSubscriptionId": {
        "type": "String",
        "value": "12345678-1234-1234-1234-123456789abc"
      },
      "customerTenantId": {
        "type": "String",
        "value": "12345678-1234-1234-1234-123456789abc"
      },
      "keyVaultName": {
        "type": "String",
        "value": "kv-u2ptq2ne5eg3a"
      },
      "keyVaultSecretProviderManagedIdentity": {
        "type": "String",
        "value": "0fc1e47a-8448-4471-b431-2e4f370bded1"
      }
    },
```

## Deploy application

1. To deploy the Kubernetes application, **you will need to work in your own copy of this repo**
1. The application is deployed using GitHub actions in a workflow at `/.github/workflows/k8s-deploy-manifest.yml`
1. Navigate to your repo on [GitHub](https://www.github.com)
1. Then go to `Settings` -> `Secrets` -> `Actions`
1. Create the following (action) secrets:
    * `AZURE_CREDENTIALS` (see [this link](https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret))
    * `AZURE_SUBSCRIPTION_ID` - the `customer` subscription ID (see outputs: `customerSubscriptionId`)
    * `AZURE_TENANT_ID` - the `customer` tenant ID (see outputs: `customerTenantId`)
    * `CLUSTER_NAME` - the AKS cluster name (set to `aks101cluster-vmss`)
    * `KV_NAME` - the KV name (see outputs: `keyVaultName`)
    * `KV_SECRET_PROVIDER_IDENTITY`(see outputs: `keyVaultSecretProviderManagedIdentity`)
    * `RESOURCE_GROUP_NAME` (see outputs: `customerManagedResourceGroupName`)
1. Before running the workflow, you need to make a minor change to the application manifest
1. In your copy of the repo, open up `/app/deployment/yml` - this is the Kubernetes manifest
1. On line 18, update the image reference to point to your container registry repo

    ```yaml
    image: <acrname>.azurecr.io/inspectorgadget:latest
    ```

1. Make sure you do not change the indentation - this is important in YAML
1. Save, commit and push your changes to GitHub
1. Confirm you can see your changes refected on GitHub
1. Run the `Build and deploy an app to AKS` workflow via the GitHub UI
   1. On GitHub, navigate to `Actions`
   1. Under `Workflows` select `Build and deploy an app to AKS`
   1. Select `Run workflow` and click the `Run workflow` button that appears

## Usage
