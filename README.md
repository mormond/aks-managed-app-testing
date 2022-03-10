# Managed Application - Azure Kubernetes Service (AKS) and Key Vault 

Based on the [Azure Kubernetes Service (AKS) quickstart](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.kubernetes/aks-vmss-systemassigned-identity#azure-kubernetes-service-aks) for the purposes of testing specific scenarios involving AKS and Azure Managed Applications.

## Overview

The objective is to create an **Azure managed application** which will deploy (**via marketplace**) an AKS cluster with access to secrets stored in the publisher tenant. The cluster should also be capable of pulling *private* images from a container registry.

This template deploys a managed **Azure hosted Kubernetes cluster** via **Azure Kubernetes Service (AKS)** with **Virtual Machine Scale Sets** Agent Pool and **System-assigned managed identity**. It also deploys a **Key Vault** for storing secrets.

**VMSS based agent pools** gives **AKS cluster** **auto-scaling** capabilities.
See [https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#about-the-cluster-autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#about-the-cluster-autoscaler) for detailed information about cluster auto-scaler.

**System-assigned managed identity**, frees up an operational cost by taking care of the identity component of Kubernetes cluster resource, and allows for a improved seamless CI/CD automation, by removing service principal prerequisite, and the long term secret rotation operations of the credential.  

**Note**: at the time of writing (March 2022), **managed identity** does not support cross-tenant scenarios (such as pulling an image from an Azure Container Registry (ACR) in the publisher tenant by an AKS Cluster in a diffent tenant, ie the customer tenant). Therefore, for the scenario of a managed application deployed via marketplace (inherently cross-tenant) we need a different approach.

It is possible to use a **Service Principal** but this sample retains **Managed Identity** for the Cluster for all the benefits that brings combined with an image pull secret for accessing the container registry.

## Sample overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

* A **Managed application** resource (in the application resource group)
* A **Kubernetes service** resource (in the managed resource group)
* A **Key Vault** resource (in the managed resource group)

The deployment will also create another `Managed` Resource Group with name `MC_{ManagedResourceGroupName}_{AksClusterName}_{AksResourceLocation}` which will be managed by the cluster and used to provision cluster resources.  

* The **customer** has access to the **application resource group**
* The **publisher** has access to the **managed resource group**
* Both **customer and publisher** have access to the **third resource group**

For more details see [Azure managed applications overview](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/overview)

## Deployment steps

### Pre-reqs
Before deployment you will need the following resources deployed in the `publisher` tenant

* A Key vault (KV) resource 
* An Container registry (ACR) resource 

### Configuration

* On the **KV resource**
    1. Create three secrets
        * `info-message` set this to any string eg 'Hello!'
        * `background-color` set this to a valid HTML color name eg 'MediumSeaGreen'
        * `acr-token` we will set this later...
    1. Set the `Enable access to Azure Resource Manager for template deployment` option
    1. Assign the **Contributor** role to the `Appliance Resource Provider` user at the key vault scope.
    * The `info-message` will be displayed on the inspector gadget site and it's background will be set to the `background-color`. We need the `acr-token` to authenticate with ACR to pull the private image.
    * For more details see [Access Key Vault secret when deploying Azure Managed Applications](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/key-vault-access)
* With the **ACR resource**
    1. Pull the latest [Inspector Gadget image](https://hub.docker.com/r/jelledruyts/inspectorgadget)
    1. Push the image to your registry eg
    ```
    docker pull jelledruyts/inspectorgadget 
    docker push <acrname>.azurecr.io/inspectorgadget
    ```

## Usage

### Connect

How to connect to the solution

The template deployment will output `controlPlaneFQDN` value while will be the Kubernetes API endpoint for the cluster.  

Sample Output:

```
Outputs:
Name                Type                       Value
==================  =========================  ==========
controlPlaneFQDN    String                     #{Your DNS Prefix}#-a38a5fa0.hcp.#{AksResourceLocation}#.azmk8s.io
```

#### Management

How to manage the solution

To get your credentials for your kubectl-cli you can use the Azure CLI command: 

```bash
az aks get-credentials --name MyManagedCluster --resource-group MyResourceGroup
```

## Notes

Solution notes

`Tags: AKS, Azure Kubernetes Service, Virtual Machine Scale Sets`
