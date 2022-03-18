# ARM Template Deployment

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

[Continure to Application Deployment](./deploy-app.md)
