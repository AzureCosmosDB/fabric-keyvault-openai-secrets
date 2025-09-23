# fabric-keyvault-openai-secrets

This repository deploys an Azure KeyVault via [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) for use with Microsoft Fabric Notebooks and Workspace Identity. The template creates an Azure OpenAI account and stores its secrets in the KeyVault for secure access from Fabric notebooks.

## Features

- 🔐 **Azure KeyVault** with proper access policies for Fabric Workspace Identity
- 🤖 **Azure OpenAI** with GPT-4 and GPT-3.5 Turbo model deployments  
- 🔑 **Automatic secret storage** of OpenAI endpoint and API key in KeyVault
- 🚀 **One-command deployment** using Azure Developer CLI
- 📋 **Pre-configured access policies** for seamless Fabric integration

## Prerequisites

1. [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
2. [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
3. An Azure subscription with permissions to create resources
4. A Microsoft Fabric workspace

## Quick Start

### 1. Clone and Initialize

```bash
azd init --template AzureCosmosDB/fabric-keyvault-openai-secrets
cd fabric-keyvault-openai-secrets
```

### 2. Find Your Fabric Workspace Object ID

To find your Fabric Workspace Service Principal Object ID:

**Option A: Using the provided helper script**
```bash
./scripts/find-workspace-sp.sh "Your-Fabric-Workspace-Name"
```

**Option B: Using Azure CLI**
```bash
az ad sp list --display-name "Your-Fabric-Workspace-Name" --query "[0].id" -o tsv
```

**Option C: Using Azure Portal**
1. Go to [Azure Active Directory](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview)
2. Select **Enterprise applications**
3. Search for your Fabric workspace name
4. Copy the **Object ID** from the application details

### 3. Set Environment Variables

Copy the example environment file and update with your values:

```bash
cp .env.example .env
```

Edit `.env` with your specific values:
```bash
AZURE_ENV_NAME=dev
AZURE_LOCATION=eastus
AZURE_FABRIC_WORKSPACE_NAME=your-fabric-workspace-name
AZURE_FABRIC_WORKSPACE_OBJECT_ID=your-workspace-object-id
```

### 4. Deploy

```bash
azd up
```

This will:
- Create a resource group
- Deploy Azure KeyVault with Fabric workspace access
- Deploy Azure OpenAI with GPT models
- Store OpenAI secrets in KeyVault
- Output the KeyVault details for use in Fabric

## Using in Microsoft Fabric Notebooks

After deployment, use the KeyVault in your Fabric notebooks:

```python
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

# Get the KeyVault URI from deployment outputs
keyvault_uri = "https://your-keyvault-name.vault.azure.net/"

# Use Fabric's managed identity to authenticate
credential = DefaultAzureCredential()
client = SecretClient(vault_url=keyvault_uri, credential=credential)

# Retrieve OpenAI secrets
openai_endpoint = client.get_secret("openai-endpoint").value
openai_api_key = client.get_secret("openai-api-key").value

# Use with OpenAI
import openai
openai.api_base = openai_endpoint
openai.api_key = openai_api_key
```

## Outputs

After successful deployment, you'll receive:

- `AZURE_KEYVAULT_NAME`: Name of the created KeyVault
- `AZURE_KEYVAULT_URI`: URI for accessing the KeyVault
- `AZURE_OPENAI_NAME`: Name of the OpenAI service
- `AZURE_OPENAI_ENDPOINT_SECRET_NAME`: Name of the secret containing OpenAI endpoint
- `AZURE_OPENAI_API_KEY_SECRET_NAME`: Name of the secret containing OpenAI API key

## Clean Up

To remove all deployed resources:

```bash
azd down
```

## Security Notes

- KeyVault access policies are configured for least privilege
- OpenAI API keys are stored securely in KeyVault
- Fabric workspace gets read-only access to secrets
- Soft delete is enabled for KeyVault recovery

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
