targetScope = 'managementGroup'
resource Assign_Azure_Lighthouse 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'Assign-Azure-Lighthouse'
  properties: {
    displayName: 'Assign Azure Lighthouse at subscription scopes'
    description: 'Policy to automatically create Azure Lighthouse delegations on subscription scopes for the specified definition. Use exclusions to prevent assignment on specific subscriptions.'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Lighthouse'
    }
    parameters: {
      lighthouseDefinitionId: {
        type: 'String'
        metadata: {
          displayName: 'Azure Lighthouse definition ID'
          description: 'Resource ID for the Azure Lighthouse definition to check and assign.'
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Resources/subscriptions'
      }
      then: {
        effect: 'DeployIfNotExists'
        details: {
          type: 'Microsoft.ManagedServices/registrationAssignments'
          deploymentScope: 'subscription'
          existenceScope: 'subscription'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.ManagedServices/registrationAssignments/registrationDefinitionId'
                equals: '[parameters(\'lighthouseDefinitionId\')]'
              }
            ]
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
          ]
          deployment: {
            location: 'UK South'
            properties: {
              mode: 'incremental'
              parameters: {
                lighthouseDefinitionId: {
                  value: '[parameters(\'lighthouseDefinitionId\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  lighthouseDefinitionId: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    type: 'Microsoft.ManagedServices/registrationAssignments'
                    apiVersion: '2022-10-01'
                    name: '[guid(parameters(\'lighthouseDefinitionId\'))]'
                    properties: {
                      registrationDefinitionId: '[parameters(\'lighthouseDefinitionId\')]'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}
