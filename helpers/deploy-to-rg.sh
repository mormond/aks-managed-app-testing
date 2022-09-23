# Useful snippets of script

# Generate ARM templace from Bicep file
az bicep build --file ./bicep/mainTemplate.bicep

# Resource group deployment of ARM template
SUB_ID=""
RG=""
DNS_PREFIX=""
KV_NAME=""

if [[ "${SUB_ID}" == "" ]]; then 
    echo "Please supply a subscription ID."
fi

if [[ "${RG}" == "" ]]; then 
    echo "Please supply a resource group."
fi

if [[ "${DNS_PREFIX}" == "" ]]; then 
    echo "Please supply a DNS prefix."
fi


if [[ "${KV_NAME}" == "" ]]; then 
    echo "Please supply the name of the 'source' key vault ."
fi

if [[ $(az group exists --resource-group "${RG}") == 'true' ]]; then

    az group create \
        --location "westeurope" \
        --resource-group "${RG}"

    az deployment group create \
        --resource-group "${RG}" \
        --template-file "./bicep/mainTemplate.json" \
        --parameters vaultSubscriptionId="${SUB_ID}" dnsPrefix="${DNS_PREFIX}" vaultName="${KV_NAME}"
else
   echo "Resource group exists"
fi