RG='appDefinitionGroup'
STORAGE_ACCOUNT_NAME='packagestoragemeo'
CONTAINER_NAME='definitions'
DISPLAY_NAME="ManagedAksWithKv"
DESCRIPTION="Managed App that deploys AKS cluster and KV"

az storage blob upload \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --container-name "$CONTAINER_NAME" \
    --name "package.zip" \
    --file "package.zip"
	
BLOB=$(az storage blob url --account-name "$STORAGE_ACCOUNT_NAME" --container-name "$CONTAINER_NAME" --name app.zip --output tsv)

USER_ID=$(az ad signed-in-user show --query objectId --output tsv)
OWNER_ID=$(az role definition list --name Owner --query [].name --output tsv)

az managedapp definition create \
  --name "ManagedAksWithKv" \
  --location "westeurope" \
  --resource-group "$RG" \
  --lock-level ReadOnly \
  --display-name "$DISPLAY_NAME" \
  --description "$DESCRIPTION" \
  --authorizations "$USER_ID:$OWNER_ID" \
  --package-file-uri "$BLOB"