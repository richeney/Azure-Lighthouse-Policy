# Azure Lighthouse policy definition

Azure Policy designed for management group assignment. The policy will automatically assign an Azure Lighthouse definition to new subscriptions using a _deploy if not exists_ policy effect.

- The policy is defined with no parameters
- Specify a single parameter for the definition resource ID when assigning
- New subscriptions created under the management group are automatically delegated
- Policy assignments can exclude areas
  - e.g. assign at Azure Landing Zone and exclude Decommissioned and Sandpit scopes
- The _deploy if not exists effect_ supports remediation of non-compliant subscriptions

The example commands assume you are creating the policy definition at the management group es.

## CLI examples

### Azure CLI with the ARM template

```shell
uri="https://raw.githubusercontent.com/richeney/policy_definition/refs/heads/main/lighthouse.policy_definition.json"
az deployment mg create --management-group-id es --name lighthouse --location uksouth --template-uri $uri
```

### PowerShell with the Bicep file

```powershell
$uri = "https://raw.githubusercontent.com/richeney/policy_definition/refs/heads/main/lighthouse.policy_definition.bicep"
New-AzManagementGroupDeployment -ManagementGroupId 'es' -Name 'lighthouse' -Location 'uksouth' -TemplateUri $uri
```

## Terraform example

This is a fuller example creating

- the Azure Lighthouse definition(s)
- the policy definition
- creating the policy assignment(s) at the same management group scope

```ruby
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "lighthouse_definition" {
  for_each        = toset(["standard"])
  source          = "github.com/Cloud-Direct/Azure-Lighthouse-Definition?ref=v1.0"
  parms           = "lighthouse.${each.value}.parameters.json"
  subscription_id = var.subscription_id
}

module "lighthouse_policy" {
  source              = "github.com/richeney/policy_definition?ref=v1.0"
  management_group_id = "es"
}

resource "azurerm_management_group_policy_assignment" "lighthouse_policy" {
  for_each             = toset(["standard"])
  name                 = "lighthouse-policy"
  location = "UK South"
  policy_definition_id = module.lighthouse_policy.policy_definition_id
  management_group_id  = module.lighthouse_policy.management_group_resource_id

  parameters = jsonencode({
    lighthouseDefinitionId = {
      value = module.lighthouse_definition[each.key].id
    }
  })

  identity {
    type = "SystemAssigned"
  }
}
```

## Permissions

When this policy is assigned, it will creates a system assigned managed identity for policy's deploy if not exist effect

- the policy assignment's system assigned managed identity will have Owner role
- the policy will only deploy the template explicit with the effect section of the [template](./lighthouse.policy_definition.json#L59)
- the Owner role is required for Azure Lighthouse assignments ([ref](https://learn.microsoft.com/azure/lighthouse/how-to/onboard-customer#deploy-the-azure-resource-manager-template))
- the managed identity will need read permissions on the Azure Lighthouse definition

## Bicep

The bicep file is a straight decompilation from the ARM template.

```shell
az bicep decompile --file lighthouse.policy_definition.json
```
