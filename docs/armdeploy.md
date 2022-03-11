# ARM template deployment

1. You must deploy the template to a subscription backed by the `publisher tenant`
1. Login to the target subscription
1. Edit the script `helpers/deploy-to-rg.sh` and set values for
    * `SUB_ID` - the subscription ID of the **source** KV
    * `RG` - resource group name for deployment
    * `DNS_PREFIX` - a DNS prefix for the FQDN eg 'meo'
1. Run the script to deploy the services
1. When the deployment is complete, **capture the outputs** which will be needed for the next steps
1. To deploy the application, fork or duplicate this repo to create your own GitHub repo
1. Create the following (action) secrets:
    * `AZURE_CREDENTIALS` (see [this link](https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret))
    * `AZURE_SUBSCRIPTION_ID`- the `customer` subscription ID (see outputs: `customerSubscriptionId`)
    * `AZURE_TENANT_ID` - the `customer` tenant ID (see outputs: `customerTenantId`)
    * `CLUSTER_NAME` - the AKS cluster name (set to `aks101cluster-vmss`)
    * `KV_NAME` - the KV name (see outputs: `keyVaultName`)
    * `KV_SECRET_PROVIDER_IDENTITY`(see outputs: `keyVaultSecretProviderManagedIdentity`)
    * `RESOURCE_GROUP_NAME` (see outputs: `customerManagedResourceGroupName`)

## Usage
