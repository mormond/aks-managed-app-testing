# Application deployment

## Overview

The application is a simple web app which can be used to inspect the host web server as well as perform other tasks. It's convenient
for our purposes as a simple way to demonstrate we have copied secrets from the **publisher tenant** and propagated them through to the
application. We have set secrets for the background colour and an information message.

The application is described in a simple manifest file at `app/deployment/yml` which creates a deployment, service and secret provider.

## Deploying the manifest

1. To deploy the application, **you will need to work in your own copy of this repo**
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
1. Click on the workflow run and you can monitor progress
1. When the run completes, click on step `Get external IP` to get the IP address of the application
1. Navigate to the IP address and confirm the inspector gadget home page appears with a coloured background (set by `background-color`) and and info message (set by `info-message`)

  ![Image of inspector gadget hompage](images/inspector-gadget.png)

## Automating Application Deployment

It is possible to completely automate this process such that each successful deployment of the managed application will invoke a deployment of the K8S to the deployed managed app instance.

Managed applications have a [notification feature](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/publish-notifications) we can use to listen for events.

This allows us to listen for the successful deployment notification and invoke the GitHub action to deploy the K8S app.

For more impementation details see this repo [Marketplace Notifications Webhook](https://github.com/mormond/marketplace-notifications-webhook).