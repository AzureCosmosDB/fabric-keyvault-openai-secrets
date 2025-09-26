@description('Name of the OpenAI service')
param name string

@description('Location for the OpenAI service')
param location string

@description('SKU for the OpenAI service')
param sku string

@description('Principal ID of the user deploying the template')
param principalId string

@description('Object ID of the Fabric Workspace Service Principal')
param fabricWorkspaceObjectId string

@description('Tags to apply to the resource')
param resourceTags object

// OpenAI Cognitive Services account
resource openAIAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  kind: 'OpenAI'
  tags: resourceTags
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
  sku: {
    name: sku
  }
}

// Role assignment to give the deploying user Cognitive Services OpenAI User role
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAIAccount.id, principalId, 'Cognitive Services OpenAI User')
  scope: openAIAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd') // Cognitive Services OpenAI User
    principalId: principalId
    principalType: 'User'
  }
}

// Role assignment to give the Fabric Workspace Service Principal Cognitive Services OpenAI User role (only if workspace object ID is provided)
resource fabricWorkspaceRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(fabricWorkspaceObjectId)) {
  name: guid(openAIAccount.id, fabricWorkspaceObjectId, 'Cognitive Services OpenAI User')
  scope: openAIAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd') // Cognitive Services OpenAI User
    principalId: fabricWorkspaceObjectId
    principalType: 'ServicePrincipal'
  }
}

// GPT deployment
resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAIAccount
  name: 'gpt-4.1-mini'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4.1-mini'
      version: '2025-04-14'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'GlobalStandard'
    capacity: 100
  }
}

// Embedding deployment
resource embeddingsDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAIAccount
  name: 'text-embedding-3-large'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-large'
      version: '1'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 90
  }
  dependsOn: [
    gptDeployment
  ]
}

// Outputs
output name string = openAIAccount.name
output id string = openAIAccount.id
output endpoint string = openAIAccount.properties.endpoint
output gptModelName string = gptDeployment.name
output embeddingModelName string = embeddingsDeployment.name
// Note: API key is retrieved securely within the secrets module
