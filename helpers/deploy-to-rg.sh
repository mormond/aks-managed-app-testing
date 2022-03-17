# Useful snippets of script

# Generate ARM templace from Bicep file
az bicep build --file ./bicep/mainTemplate.bicep

# Resource group deployment of ARM template
SUB_ID=""
RG=""
DNS_PREFIX=""

if [[ "${RG}" == "" ]]; then 
    echo "Please supply a resource group."
fi

if [[ "${SUB_ID}" == "" ]]; then 
    echo "Please supply a subscription ID."
fi

if [[ $(az group exists --resource-group "${RG}") == 'false' ]]; then

    az group create \
        --location "westeurope" \
        --resource-group "${RG}"

    az deployment group create \
        --resource-group "${RG}" \
        --template-file "./bicep/mainTemplate.json" \
        --parameters vaultSubscriptionId="${SUB_ID}" dnsPrefix="${DNS_PREFIX}"
else
   echo "Resource group exists"
fi