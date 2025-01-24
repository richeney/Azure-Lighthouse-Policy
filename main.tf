locals {
  management_group_resource_id = var.management_group_id != null ? "/providers/Microsoft.Management/managementGroups/${basename(var.management_group_id)}" : null
}

resource "azurerm_policy_definition" "assign_azure_lighthouse" {
  name                = "Assign-Azure-Lighthouse"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Assign Azure Lighthouse at subscription scopes"
  description         = "Policy to automatically create Azure Lighthouse delegations on subscription scopes for the specified definition. Use exclusions to prevent assignment on specific subscriptions."
  management_group_id = local.management_group_resource_id

  metadata = jsonencode({
    category = "Lighthouse"
  })

  parameters = jsonencode({
    lighthouseDefinitionId = {
      type = "String"
      metadata = {
        displayName = "Azure Lighthouse definition ID"
        description = "Resource ID for the Azure Lighthouse definition to check and assign."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Resources/subscriptions"
    }
    then = {
      effect = "DeployIfNotExists"
      details = {
        type            = "Microsoft.ManagedServices/registrationAssignments"
        deploymentScope = "subscription"
        existenceScope  = "subscription"

        existenceCondition = {
          allOf = [
            {
              field  = "Microsoft.ManagedServices/registrationAssignments/registrationDefinitionId"
              equals = "[parameters('lighthouseDefinitionId')]"
            }
          ]
        }

        roleDefinitionIds = [
          "/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
        ]

        deployment = {
          location = "UK South"
          properties = {
            mode = "incremental"
            parameters = {
              lighthouseDefinitionId = {
                value = "[parameters('lighthouseDefinitionId')]"
              }
            }
            template = {
              "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
              contentVersion = "1.0.0.0"

              parameters = {
                lighthouseDefinitionId = {
                  type = "String"
                }
              }

              resources = [{
                type       = "Microsoft.ManagedServices/registrationAssignments"
                apiVersion = "2022-10-01"
                name       = "[guid(parameters('lighthouseDefinitionId'))]"
                properties = {
                  registrationDefinitionId = "[parameters('lighthouseDefinitionId')]"
                }
              }]
            }
          }
        }
      }
    }
  })
}
