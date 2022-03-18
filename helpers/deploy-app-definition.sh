# The name of the storage account / container to be created
# STORAGE_ACCOUNT_NAME must be unique across Azure
STORAGE_ACCOUNT_NAME='packagestorage'
CONTAINER_NAME='definitions'

# The resource group / location where the storage account and 
# managed app definition will be created
RG='appDefinitionGroup'
LOCATION='westeurope'

# Properties of the managed app definition
NAME='ManagedAksWithKv'
DISPLAY_NAME='ManagedAksWithKv'
DESCRIPTION='Managed App that deploys AKS cluster and KV'

# The name of the package in blob storage
PACKAGE_NAME='package.zip'

# Set this to the name of the SP you will use to authenticate
SP_NAME='aks-managed-app-test'

## ## ## ## ## ## ## ## ## ## ## ##
## Upload package to blob storage
## ## ## ## ## ## ## ## ## ## ## ##

# Create a new storage account
az storage account create \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --resource-group "${RG}" \
  --location "${LOCATION}"

# Create a container in the storage account
az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT_NAME}"

# Upload local package file to blob storage
az storage blob upload \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --container-name "${CONTAINER_NAME}" \
    --name "${PACKAGE_NAME}" \
    --file "package.zip"

## ## ## ## ## ## ## ## ## ## ## ## ## ##
## Assign RBAC roles for storage account
## ## ## ## ## ## ## ## ## ## ## ## ## ##

# Get current user objectId , SP objectId and Owner role definition ID
USER_ID=$(az ad signed-in-user show --query objectId --output tsv)
SP_ID=$(az ad sp list --display-name "${SP_NAME}" --query [].objectId --output tsv)
OWNER_ROLE_ID=$(az role definition list --name "Owner" --query [].name --output tsv)
STORAGE_ROLE_ID=$(az role definition list --name "Storage Blob Data Contributor" --query [].name --output tsv)

STORAGE_ACCOUNT_ID=$( \
  az resource show \
    --resource-group "${RG}" \
    --resource-type "Microsoft.Storage/storageAccounts" \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --query id \
    --output tsv)

az role assignment create \
  --assignee "${USER_ID}" \
  --role "${OWNER_ID}" \
  --scope "${STORAGE_ACCOUNT_ID}"

az role assignment create \
  --assignee "${USER_ID}" \
  --role "${STORAGE_ROLE_ID}" \
  --scope "${STORAGE_ACCOUNT_ID}"

## ## ## ## ## ## ## ## ## ## ## ##
## Generate a SAS URI to use
## ## ## ## ## ## ## ## ## ## ## ##

# Get the blob URL
BLOB=$( \
  az storage blob url \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --container-name "${CONTAINER_NAME}" \
  --name "${PACKAGE_NAME}" \
  --output tsv)

EXPIRY=$(date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ')

SAS_TOKEN=$( \
az storage container generate-sas \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --name "${CONTAINER_NAME}" \
  --expiry "${EXPIRY}" \
  --permissions "lr" \
  --auth-mode login \
  --as-user \
  --output tsv)

BLOB_URL="${BLOB}?${SAS_TOKEN}"

## ## ## ## ## ## ## ## ## ## ## ##
## Create a managed app definition
## ## ## ## ## ## ## ## ## ## ## ##

# Create a managed app definition from the package
az managedapp definition create \
  --name "${NAME}" \
  --location "${LOCATION}" \
  --resource-group "${RG}" \
  --lock-level ReadOnly \
  --display-name "${DISPLAY_NAME}" \
  --description "${DESCRIPTION}" \
  --authorizations "${USER_ID}:${OWNER_ROLE_ID}" "${SP_ID}:${OWNER_ROLE_ID}" \
  --package-file-uri "${BLOB_URL}"
