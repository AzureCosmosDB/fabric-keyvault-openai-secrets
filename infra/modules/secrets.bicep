@description('Name of the KeyVault to store secrets in')
param keyVaultName string

@description('Name of the OpenAI account to get the API key from')
param openAIAccountName string

@description('OpenAI endpoint URL')
param openAIEndpoint string

// Reference to existing KeyVault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Reference to existing OpenAI account to get the API key
resource openAIAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: openAIAccountName
}

// Store OpenAI endpoint as a secret
resource openAIEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'openai-endpoint'
  properties: {
    value: openAIEndpoint
    attributes: {
      enabled: true
    }
  }
}

// Store OpenAI API key as a secret
resource openAIApiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'openai-api-key'
  properties: {
    value: openAIAccount.listKeys().key1
    attributes: {
      enabled: true
    }
  }
}

// Outputs
output endpointSecretName string = openAIEndpointSecret.name
output apiKeySecretName string = openAIApiKeySecret.name