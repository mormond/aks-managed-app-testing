# The name of the storage account / container to be created
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

## ## ## ## ## ## ## ## ## ## ## ##
## Upload package to blob storage
## ## ## ## ## ## ## ## ## ## ## ##

# Create a new storage account
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RG" \
  --location "$LOCATION"

# Create a container in the storage account
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME"

# Upload local package file to blob storage
az storage blob upload \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --container-name "$CONTAINER_NAME" \
    --name "$PACKAGE_NAME" \
    --file "package.zip"

## ## ## ## ## ## ## ## ## ## ## ##
## Create a managed app definition
## ## ## ## ## ## ## ## ## ## ## ##

# Get the blob URL
BLOB=$(az storage blob url --account-name "$STORAGE_ACCOUNT_NAME" --container-name "$CONTAINER_NAME" --name "$PACKAGE_NAME" --output tsv)

# Get current user ObjectId and Owner role definition ID
USER_ID=$(az ad signed-in-user show --query objectId --output tsv)
OWNER_ID=$(az role definition list --name Owner --query [].name --output tsv)

# Create a managed app definition from the package
az managedapp definition create \
  --name "$NAME" \
  --location "$LOCATION" \
  --resource-group "$RG" \
  --lock-level ReadOnly \
  --display-name "$DISPLAY_NAME" \
  --description "$DESCRIPTION" \
  --authorizations "$USER_ID:$OWNER_ID" \
  --package-file-uri "$BLOB"
