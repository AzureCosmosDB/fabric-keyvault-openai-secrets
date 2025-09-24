# Store Azure OpenAI Secrets in KeyVault for Microsoft Fabric Notebooks

Microsoft Fabric Notebooks does not support Entra ID authentication to Azure OpenAI resources within a Fabric Notebook. Users must use key-based authentication. To do so securely, Azure OpenAI keys must be stored in Azure KeyVault and accessed using the Service Principal for the Fabric Workspace Identity.

This repository deploys an Azure KeyVault via [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) for use with Microsoft Fabric Notebooks and Workspace Identity. The template creates an Azure OpenAI account with the latest models and stores its secrets in the KeyVault for secure access from Fabric Notebooks.

## Features

- 🔐 **Azure KeyVault** with proper access policies for Fabric Workspace Identity
- 🤖 **Azure OpenAI** with GPT-4.1 and Text-Embedding-3-Large model deployments  
- 🔑 **Automatic secret storage** of OpenAI endpoint and API key in KeyVault
- 🏷️ **Resource tagging** with owner, environment, and workspace information
- 🔒 **Role-based access** for Fabric workspace to OpenAI
- 🔍 **Automatic workspace discovery** during deployment
- 🚀 **One-command deployment** using Azure Developer CLI
- 📋 **Pre-configured access policies** for seamless Fabric integration

## Prerequisites

1. [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
2. [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
3. An Azure subscription with permissions to create resources (e.g. Subscription OWNER)
4. A Microsoft Fabric workspace

## Quick Start

### 1. Clone and Initialize

```bash
azd init --template AzureCosmosDB/fabric-keyvault-openai-secrets
cd fabric-keyvault-openai-secrets
```

### 2. Deploy with Interactive Setup

```bash
azd up
```

During deployment, you'll be prompted to:

- **Enter your Fabric workspace name** The deployment will automatically look up the workspace Service Principal
- **Set your Azure location**: Choose the region for your resources
- **Configure environment name**: Used for resource naming and tagging

The deployment will:

- Automatically discover your user information for resource tagging
- Look up your Fabric workspace Service Principal (if workspace name provided)
- Create tagged resources with owner and workspace information
- Deploy Azure KeyVault with proper access policies
- Deploy Azure OpenAI with latest GPT-4.1 and Text-Embedding-3-Large models
- Configure role-based access for your Fabric workspace
- Store OpenAI secrets in KeyVault

## Using Deployment Outputs in Microsoft Fabric Notebooks

After deployment, your Bicep template outputs all the configuration values you need to connect to Azure OpenAI from your Fabric Notebooks. These outputs appear in the deployment results and can be retrieved anytime using:

```bash
az deployment sub show --name "<your-deployment-name>" --query "properties.outputs" --output json
```

### 📋 Available Output Values

The deployment provides these ready-to-use values:

#### These three are what you need to authenticate Azure OpenAI in a Fabric Notebook

- **`KEYVAULT_URI`**: KeyVault endpoint (e.g., `"https://kv-my-keyvault.vault.azure.net/"`)
- **`KEYVAULT_OPENAI_ENDPOINT_SECRET_NAME`**: Secret name for OpenAI endpoint (e.g., `"openai-endpoint"`)
- **`KEYVAULT_OPENAI_API_KEY_SECRET_NAME`**: Secret name for API key (e.g., `"openai-api-key"`)

- **`KEYVAULT_NAME`**: KeyVault name (e.g., `"kv-my-keyvault"`)
- **`OPENAI_NAME`**: OpenAI service name (e.g., `"cog-myopenaiaccount"`)
- **`OPENAI_GPT_MODEL_NAME`**: GPT model deployment name (e.g., `"gpt-4.1"`)
- **`OPENAI_EMBEDDING_MODEL_NAME`**: Embedding model name (e.g., `"text-embedding-3-large"`)

### 🚀 Copy-Paste Ready Notebook Code

Use these output values directly in your Fabric Notebooks:

#### Method 1: Using KeyVault Secrets (Recommended for API Key Authentication)

```python
# Packages
%pip install openai

# Imports
from notebookutils import mssparkutils
from openai.lib.azure import AsyncAzureOpenAI

# Variables, copy these directly from azd output in the terminal
KEYVAULT_URI="https://kv-my-keyvault.vault.azure.net/"
KEYVAULT_OPENAI_ENDPOINT_SECRET_NAME="openai-endpoint"
KEYVAULT_OPENAI_API_KEY_SECRET_NAME="openai-api-key"

OPENAI_ENDPOINT=mssparkutils.credentials.getSecret(KEYVAULT_URI, KEYVAULT_OPENAI_ENDPOINT_SECRET_NAME)
OPENAI_KEY=mssparkutils.credentials.getSecret(KEYVAULT_URI, KEYVAULT_OPENAI_API_KEY_SECRET_NAME)
OPENAI_API_VERSION="2024-12-01-preview"
OPENAI_EMBEDDING_DIMENSIONS=512
OPENAI_EMBEDDING_MODEL_DEPLOYMENT="text-embedding-3-large"


# Initialize Azure OpenAI client using keys from KeyVault
OPENAI_CLIENT = AsyncAzureOpenAI(
    api_version=OPENAI_API_VERSION,
    azure_endpoint=OPENAI_ENDPOINT,
    api_key=OPENAI_KEY
)

# Define function to generate embeddings for vector search
async def generate_embeddings(text):
    
    response = await OPENAI_CLIENT.embeddings.create(
        input = text, 
        dimensions = OPENAI_EMBEDDING_DIMENSIONS,
        model = OPENAI_EMBEDDING_MODEL_DEPLOYMENT)
    
    embeddings = response.model_dump()
    return embeddings['data'][0]['embedding']

# Generate Embeddings from Azure OpenAI in a Fabric Notebook
search_text = "Hello from Fabric Notebooks!"
embeddings = await generate_embeddings(search_text.strip())
print(embeddings)
```

### 💡 Key Benefits of Using Deployment Outputs

1. **No Hard-Coding**: Use the exact model deployment names from your infrastructure
2. **Environment Consistency**: Same code works across dev/test/prod environments
3. **Easy Updates**: Change model versions in Bicep, redeploy, and use new output values
4. **Secure Access**: KeyVault integration with Fabric Workspace Identity

## Deployed Models

The template deploys the latest OpenAI models:

- **GPT-4.1**: Latest conversational AI model with 1M token context for chat and text generation
- **Text-Embedding-3-Large**: Advanced embeddings model for semantic search and similarity

## Resource Tagging

All deployed resources are automatically tagged with:

- **Owner**: Your Azure user principal name (email)
- **Environment**: The azd environment name you specified
- **WorkspaceName**: Your Fabric workspace name (if provided)
- **ManagedBy**: "azd" (indicates deployment via Azure Developer CLI)

These tags help with resource management, cost tracking, and governance.

## Outputs

After successful deployment, the Bicep template outputs all the configuration values you need for your Fabric Notebooks. These values are displayed in the terminal and can be retrieved anytime using Azure CLI.

### 🎯 How to Use the Output Values

1. **Copy the output values** from your deployment results
2. **Replace the configuration variables** in the notebook code examples above
3. **Run your Fabric Notebook** with the correct resource names and model deployments

### 📋 Complete List of Outputs

- **`AZURE_LOCATION`**: Azure region where resources are deployed
- **`AZURE_TENANT_ID`**: Your Azure tenant ID
- **`AZURE_RESOURCE_GROUP`**: Name of the created resource group
- **`KEYVAULT_NAME`**: Name of the created KeyVault (use in notebook code)
- **`KEYVAULT_URI`**: URI for accessing the KeyVault
- **`KEYVAULT_OPENAI_ENDPOINT_SECRET_NAME`**: Secret name containing OpenAI endpoint
- **`KEYVAULT_OPENAI_API_KEY_SECRET_NAME`**: Secret name containing OpenAI API key
- **`OPENAI_NAME`**: Name of the OpenAI service (use in notebook code)
- **`OPENAI_GPT_MODEL_NAME`**: GPT model deployment name (use in notebook code)  
- **`OPENAI_EMBEDDING_MODEL_NAME`**: Embedding model deployment name (use in notebook code)
- **`msg`**: Custom message reminder to copy values into Fabric Notebook

### 🔍 Retrieving Output Values Anytime

You can view your deployment outputs anytime using:

```bash
# List recent deployments to find your deployment name
az deployment sub list --query "[].{Name:name, State:properties.provisioningState}" --output table

# Get outputs from a specific deployment
az deployment sub show --name "<your-deployment-name>" --query "properties.outputs" --output json
```

## Clean Up

To remove all deployed resources:

```bash
azd down
```

## Security Notes

- **Role-based access**: Fabric workspace has direct OpenAI access via managed identity (no API keys needed)
- **KeyVault access policies**: Configured for least privilege access
- **OpenAI API keys**: Stored securely in KeyVault
- **Resource tagging**: All resources tagged with owner and workspace information
- **Soft delete**: Enabled for KeyVault recovery. Use `azd down --purge --force` for hard delete
- **Principle of least privilege**: Each component has only the minimum required permissions

### Common Issues

**Workspace not found during deployment:**

- Ensure you have the correct permissions to list Enterprise Applications
- Verify the workspace name is spelled correctly
- You can skip workspace setup and set the Object ID manually later

**OpenAI models not available:**

- GPT-4.1 and Text-Embedding-3-Large may not be available in all regions
- Check Azure OpenAI model availability in your chosen region
- Consider updating the model versions in `infra/modules/openai.bicep` if needed

**Role assignment failures:**

- Ensure you have sufficient permissions in the subscription. You must be OWNER or have RBAC permissions.
- Verify the Fabric workspace Service Principal exists
- Check that the workspace is properly configured in Fabric

### Getting Help

**Note: This is best-effort supported. Not an officially supported product.**

For additional help:

- Check the [Azure Developer CLI documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- Review [Microsoft Fabric documentation](https://learn.microsoft.com/fabric/)
- Open an issue in this repository

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
