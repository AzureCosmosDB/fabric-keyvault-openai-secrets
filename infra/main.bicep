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

@description('User Principal Name for resource tagging')
param userUpn string

// Optional parameters
@description('Azure OpenAI Location (defaults to eastus)')
param openAILocation string = 'eastus'

@description('Azure OpenAI SKU (defaults to S0)')
param openAISku string = 'S0'

// Generate a unique suffix from the environment name
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var abbreviations = loadJsonContent('./abbreviations.json')

// Create tags for all resources
var commonTags = {
  Owner: userUpn
  Environment: environmentName
  FabricWorkspaceName: workspaceName
  ManagedBy: 'azd'
}

// Note: workspaceName is used for reference and future Service Principal lookup functionality

// Organize all resources in a single resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbreviations.resourceGroup}${environmentName}'
  location: location
  tags: commonTags
}

// Deploy the resources
module resources './resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    location: location
    principalId: principalId
    workspaceObjectId: workspaceObjectId
    resourceToken: resourceToken
    openAILocation: openAILocation
    openAISku: openAISku
    commonTags: commonTags
  }
}

// Outputs
output KEYVAULT_URI string = resources.outputs.KEYVAULT_URI
output KEYVAULT_OPENAI_ENDPOINT_SECRET_NAME string = resources.outputs.KEYVAULT_OPENAI_ENDPOINT_SECRET_NAME
output KEYVAULT_OPENAI_API_KEY_SECRET_NAME string = resources.outputs.KEYVAULT_OPENAI_API_KEY_SECRET_NAME
output OPENAI_NAME string = resources.outputs.OPENAI_NAME
output OPENAI_GPT_MODEL_NAME string = resources.outputs.OPENAI_GPT_MODEL_NAME
output OPENAI_EMBEDDING_MODEL_NAME string = resources.outputs.OPENAI_EMBEDDING_MODEL_NAME
output KEYVAULT_NAME string = resources.outputs.KEYVAULT_NAME
output LOCATION string = location
output TENANT_ID string = tenant().tenantId
output RESOURCE_GROUP string = rg.name

