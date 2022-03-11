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
1. Create a new `KV resource` in the resource group
1. Create a new `ACR resource` in the resource group
1. Update the Bicep template `bicep/mainTemplate.bicep` - change the default values of:
   * `vaultName` from `'kv-managedapps'` to whatever you named your KV above
   * `vaultResourceGroupName` **if** you didn't use `ManagedAppsSource`
   * `vaultSubscriptionId` from `''` to the subscription ID where the KV resides
1. Save `mainTemplate.bicep`

## Configuration

* On the **KV resource**
    1. Create three secrets
        * `info-message` set this to any string eg `'Hello!'`
        * `background-color` set this to a valid HTML color name eg `'MediumSeaGreen'`
        * `acr-token` we will set this later...
    1. Set the `Enable access to Azure Resource Manager for template deployment` option
    1. Assign the **Contributor** role to the `Appliance Resource Provider` user at the key vault scope

The `info-message` will be displayed on the inspector gadget site and it's background will be set to the `background-color`. We need the `acr-token` to authenticate with ACR to pull the private image

For more details see [Access Key Vault secret when deploying Azure Managed Applications](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/key-vault-access)

* With the **ACR resource**
    1. Pull the latest [Inspector Gadget image](https://hub.docker.com/r/jelledruyts/inspectorgadget)

    ```bash
    docker pull jelledruyts/inspectorgadget 
    ```
    <!-- markdownlint-disable-next-line MD029 -->
    2. Push the image to your registry eg

    ```bash
    docker push <acrname>.azurecr.io/inspectorgadget
    ```

This image will be pulled by nodes in the AKS cluster.

## Choose deployment method

Choose your path (ordered quickest / simplest first)

* [Arm template deployment](./armdeploy.md)
* [Catalog managed app deployment](./catalogdeploy.md)
* [Marketplace managed app deployment](./marketplacedeploy.md)
