// TODO: Add the policy definition to assign Azure Lighthouse at subscription scopes

resource "azurerm_policy_definition" "policy" {
  name         = "Assign-Azure-Lighthouse"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Assign Azure Lighthouse at subscription scopes"
  description = "Policy to automatically create Azure Lighthouse delegations on subscription scopes for the specified definition. Use exclusions to prevent assignment on specific subscriptions."

  metadata = <<-METADATA
    {
    "category": "Lighthouse"
    }
    METADATA

  parameters = <<PARAMETERS
 {
    "lighthouseDefinitionId": {
      "type": "String",
      "metadata": {
        "displayName": "Azure Lighthouse definition ID",
        "description": "Resource ID for the Azure Lighthouse definition to check and assign."
      }
    }
  }
PARAMETERS

  policy_rule = <<POLICY_RULE
 {
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE




}