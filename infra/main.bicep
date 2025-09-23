targetScope = 'resourceGroup'

@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string

@description('Object ID of the Microsoft Fabric Workspace Service Principal')
param workspaceObjectId string

@description('Resource token to make resource names unique')
param resourceToken string

@description('Azure OpenAI Location')
param openAILocation string

@description('Azure OpenAI SKU')
param openAISku string

// Load abbreviations for consistent naming
var abbreviations = loadJsonContent('./abbreviations.json')

// Use the provided workspace object ID
var fabricWorkspaceObjectId = workspaceObjectId

// Deploy Azure KeyVault
module keyVault './modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    name: '${abbreviations.keyVault}${resourceToken}'
    location: location
    principalId: principalId
    fabricWorkspaceObjectId: fabricWorkspaceObjectId
  }
}

// Deploy Azure OpenAI
module openAI './modules/openai.bicep' = {
  name: 'openai'
  params: {
    name: '${abbreviations.cognitiveServices}${resourceToken}'
    location: openAILocation
    sku: openAISku
    principalId: principalId
  }
}

// Store OpenAI secrets in KeyVault
module secrets './modules/secrets.bicep' = {
  name: 'secrets'
  params: {
    keyVaultName: keyVault.outputs.name
    openAIAccountName: openAI.outputs.name
    openAIEndpoint: openAI.outputs.endpoint
  }
}

// Outputs
output AZURE_KEYVAULT_NAME string = keyVault.outputs.name
output AZURE_KEYVAULT_URI string = keyVault.outputs.uri
output AZURE_OPENAI_NAME string = openAI.outputs.name
output AZURE_OPENAI_ENDPOINT_SECRET_NAME string = secrets.outputs.endpointSecretName
output AZURE_OPENAI_API_KEY_SECRET_NAME string = secrets.outputs.apiKeySecretName