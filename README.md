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

## Deployed resources

The following resources are deployed as part of the solution:

* A **Managed application** resource (in the application resource group)
* A **Kubernetes service** resource (in the managed resource group)
* A **Key Vault** resource (in the managed resource group)

The deployment will also create another `Managed` Resource Group with name `MC_{ManagedResourceGroupName}_{AksClusterName}_{AksResourceLocation}` which will be managed by the cluster and used to provision cluster resources:

* The **customer** has access to the **application resource group**
* The **publisher** has access to the **managed resource group**
* Both **customer and publisher** have access to the **third resource group**

For more details about **managed apps**, see [Azure managed applications overview](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/overview).

Continue to [deployment](./docs/deploy.md).
