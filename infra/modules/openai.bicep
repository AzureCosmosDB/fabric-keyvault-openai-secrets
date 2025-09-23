@description('Name of the OpenAI service')
param name string

@description('Location for the OpenAI service')
param location string

@description('SKU for the OpenAI service')
param sku string

@description('Principal ID of the user deploying the template')
param principalId string

// OpenAI Cognitive Services account
resource openAIAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  kind: 'OpenAI'
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

// GPT-4 deployment (most commonly used model)
resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAIAccount
  name: 'gpt-4'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '0613'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 10
  }
}

// GPT-3.5 Turbo deployment (cost-effective option)
resource gpt35Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAIAccount
  name: 'gpt-35-turbo'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0613'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 120
  }
  dependsOn: [
    gpt4Deployment
  ]
}

// Outputs
output name string = openAIAccount.name
output id string = openAIAccount.id
output endpoint string = openAIAccount.properties.endpoint
// Note: API key is retrieved securely within the secrets module