# Managed Application - Azure Kubernetes Service (AKS) and Key Vault 

Based on the [Azure Kubernetes Service (AKS) quickstart](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.kubernetes/aks-vmss-systemassigned-identity#azure-kubernetes-service-aks) for the purposes of testing specific scenarios involving AKS and Azure Managed Applications.

## Overview

The objective is to create an **Azure managed application** which will deploy (**via marketplace**) an AKS cluster with access to secrets stored in the publisher tenant. The cluster should also be capable of pulling *private* images from a container registry.

This template deploys a managed **Azure hosted Kubernetes cluster** via **Azure Kubernetes Service (AKS)** with **Virtual Machine Scale Sets** Agent Pool and **System-assigned managed identity**. It also deploys a **Key Vault** for storing secrets.

**VMSS based agent pools** gives **AKS cluster** **auto-scaling** capabilities.
See [https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#about-the-cluster-autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#about-the-cluster-autoscaler) for detailed information about cluster auto-scaler.

**System-assigned managed identity**, frees up an operational cost by taking care of the identity component of Kubernetes cluster resource, and allows for a improved seamless CI/CD automation, by removing service principal prerequisite, and the long term secret rotation operations of the credential.  

**Note**: at the time of writing (March 2022), managed identity does not support cross-tenant scenarios (such as pulling an image from an Azure Container Registry (ACR) in the publisher tenant by an AKS Cluster in a diffent tenant, ie the customer tenant). Therefore, for the scenario of a managed application deployed via marketplace (inherently cross-tenant) we need a different approach.

It is possible to use a **Service Principal** but this sample retains **Managed Identity* for the Cluster for all the benefits that brings combined with an image pull secret for accessing the container registry.

## Sample overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

### Resource provider Microsoft.ContainerService

Description Resource Provider Microsoft.ContainerService

+ **Resource type managedClusters**: Azure Kubernetes Service Managed Cluster

This deployment will also create another `Managed` Resource Group with name `MC_#{AksResourceGroupName}#_#{YourAksClusterName}#_#{AksResourceLocation}#` which will be managed by the cluster and used to provision cluster resources.  

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

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
