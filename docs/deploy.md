# Deployment

## Overview

It is possible to deploy the solution

* As a normal ARM template deployment
* As a **catalog managed application**
* As a **marketplace managed application**

Whilst the goal is to deploy as a **marketplace application**, it is more convenient to test using the other two approaches.

Testing a marketplace application involves a publishing step which takes a few hours, even for preview - reserve marketplace testing for a final step.

## Pre-reqs

You will need your own copy of this repo to complete all the steps. You will need to create GitHub action secrets for your deployment. **I would recommend either forking or duplicating this repo now.**

Before any deployment the following resources must exist in the `publisher tenant`:

* A Key vault (KV) resource
* An Container registry (ACR) resource

1. Create a new resource group called `ManagedAppsSource` to host these resources
   * If you pick a different name, make sure you update it in the Bicep template
1. Create a new `Key vault resource` in the resource group (Standard SKU)
1. Create a new `Container registry resource` in the resource group (Basic SKU)
1. Update the Bicep template `bicep/mainTemplate.bicep` - change the default values of:
   * `vaultName` from `'kv-managedapps'` to whatever you named your KV above
   * `vaultResourceGroupName` **if** you didn't use `ManagedAppsSource`
   * `vaultSubscriptionId` from `''` to the subscription ID where the KV resides
1. Save `mainTemplate.bicep`

## Configuration

* With the **ACR resource**
    1. Pull the latest [Inspector Gadget image](https://hub.docker.com/r/jelledruyts/inspectorgadget)

    ```bash
    docker pull jelledruyts/inspectorgadget 
    ```

    <!-- markdownlint-disable-next-line MD029 -->
    2. Tag the image

    ```bash
    docker tag jelledruyts/inspectorgadget <acrname>.azurecr.io/inspectorgadget
    ```

    <!-- markdownlint-disable-next-line MD029 -->
    3. Authenticate with the container registry

       * You will need the username and password for the container registry
       * You will find these on the `Access Keys` blade of the portal
       * Enable `Admin user` to reveal the username & password

    ```bash
    docker login <acrname>.azurecr.io
    ```

    <!-- markdownlint-disable-next-line MD029 -->
    4. Push the image to your registry eg

    ```bash
    docker push <acrname>.azurecr.io/inspectorgadget
    ```

    <!-- markdownlint-disable-next-line MD029 -->
    5. Capture the credentials
       1. The login process creates / updates a config.json file with an auth token
       1. View the config file

            ```bash
            cat ~/.docker/config.json
            ```

       1. The output should look similar to this

            ```json
            {
                "auths": {
                        "<acrname>.azurecr.io": {
                                "auth": "bWVvY...."
                        }
                }
            }
            ```

       1. Make sure you a token for the correct container registry and no other tokens
       1. base64 encode the contents of the file

            ```bash
            base64 ~/.docker/config.json
            ```

       1. Carefully copy the output to be stored in the `acr-token` in the next step

This image will be pulled by nodes in the AKS cluster.

* On the **KV resource**
    1. Create three secrets
        * `acr-token` paste in the base64 secret you generated in the previous step
        * Set the `Content type` for `acr-token` secret to `base64`
        * `info-message` set this to any string eg `'Hello!'`
        * `background-color` set this to a valid HTML color name eg `'MediumSeaGreen'`
    1. On the `Access policies` blade
       * Set the `Enable access to Azure Resource Manager for template deployment` option
       * Make sure to hit `Save`
    1. On the `Access control (IAM)` blade
       * Add a role assignment
       * Assign the **Contributor** role to the `Appliance Resource Provider` user at the key vault scope

The `info-message` will be displayed on the inspector gadget site and it's background will be set to the `background-color`. We need the `acr-token` to authenticate with ACR to pull the private image

For more details see [Access Key Vault secret when deploying Azure Managed Applications](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/key-vault-access)

## Choose deployment method

Choose your path (ordered quickest / simplest first)

* [ARM template deployment](./armdeploy.md)
* [Catalog managed app deployment](./catalogdeploy.md)
* [Marketplace managed app deployment](./marketplacedeploy.md)
