@description('Name of the KeyVault')
param name string

@description('Location for the KeyVault')
param location string

@description('Principal ID of the user deploying the template')
param principalId string

@description('Object ID of the Fabric Workspace Service Principal')
param fabricWorkspaceObjectId string

@description('Tags to apply to the resource')
param resourceTags object

// KeyVault resource
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: resourceTags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    accessPolicies: concat([
      // Access for the user deploying the template
      {
        tenantId: subscription().tenantId
        objectId: principalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'backup'
            'restore'
            'recover'
            'purge'
          ]
          keys: [
            'get'
            'list'
            'create'
            'delete'
            'backup'
            'restore'
            'recover'
            'purge'
            'encrypt'
            'decrypt'
            'sign'
            'verify'
            'wrapKey'
            'unwrapKey'
          ]
          certificates: [
            'get'
            'list'
            'create'
            'delete'
            'backup'
            'restore'
            'recover'
            'purge'
            'import'
            'update'
          ]
        }
      }
    ], !empty(fabricWorkspaceObjectId) ? [
      // Access for the Fabric Workspace Service Principal (only if provided)
      {
        tenantId: subscription().tenantId
        objectId: fabricWorkspaceObjectId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ] : [])
  }
}

// Outputs
output name string = keyVault.name
output id string = keyVault.id
output uri string = keyVault.properties.vaultUri
