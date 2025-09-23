targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the Microsoft Fabric Workspace (Service Principal will be looked up by this name)')
param workspaceName string

@description('Object ID of the Microsoft Fabric Workspace Service Principal (optional - can be found in Azure AD)')
param workspaceObjectId string = ''

@minLength(1)
@maxLength(64)
@description('Name of the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string

// Optional parameters
@description('Azure OpenAI Location (defaults to eastus)')
param openAILocation string = 'eastus'

@description('Azure OpenAI SKU (defaults to S0)')
param openAISku string = 'S0'

// Generate a unique suffix from the environment name
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var abbreviations = loadJsonContent('./abbreviations.json')

// Note: workspaceName is used for reference and future Service Principal lookup functionality

// Organize all resources in a single resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbreviations.resourceGroup}${environmentName}'
  location: location
}

// Deploy the main resources
module main './main.bicep' = {
  name: 'main'
  scope: rg
  params: {
    location: location
    principalId: principalId
    workspaceObjectId: workspaceObjectId
    resourceToken: resourceToken
    openAILocation: openAILocation
    openAISku: openAISku
  }
}

// Outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_KEYVAULT_NAME string = main.outputs.AZURE_KEYVAULT_NAME
output AZURE_KEYVAULT_URI string = main.outputs.AZURE_KEYVAULT_URI
output AZURE_OPENAI_NAME string = main.outputs.AZURE_OPENAI_NAME
output AZURE_OPENAI_ENDPOINT_SECRET_NAME string = main.outputs.AZURE_OPENAI_ENDPOINT_SECRET_NAME
output AZURE_OPENAI_API_KEY_SECRET_NAME string = main.outputs.AZURE_OPENAI_API_KEY_SECRET_NAME