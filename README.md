# Azure Lighthouse policy definition

## Overview

Azure Policy designed for management group assignment. The policy will automatically assign an Azure Lighthouse definition to new subscriptions using a _deploy if not exists_ policy effect.

- The policy is defined with no parameters
- Specify a single parameter for the definition resource ID when assigning
- New subscriptions created under the management group are automatically delegated
- Policy assignments can exclude areas
  - e.g. assign at Azure Landing Zone and exclude Decommissioned and Sandpit scopes
- The _deploy if not exists effect_ supports remediation of non-compliant subscriptions

The example commands assume you are creating the policy definition at the management group es.

## Examples

### Terraform module

```ruby
module "lighthouse_policy" {
  source              = "github.com/richeney/lighthouse_policy?ref=v0.2"
  management_group_id = "es"
}
```

### Azure CLI with the ARM template

```shell
uri="https://raw.githubusercontent.com/richeney/lighthouse_policy/refs/heads/main/lighthouse.policy_definition.json"
az deployment mg create --management-group-id es --name lighthouse --location uksouth --template-uri $uri
```

### PowerShell with the Bicep file

```powershell
$uri = "https://raw.githubusercontent.com/richeney/lighthouse_policy/refs/heads/main/lighthouse.policy_definition.bicep"
New-AzManagementGroupDeployment -ManagementGroupId 'es' -Name 'lighthouse' -Location 'uksouth' -TemplateUri $uri
```

## Permissions

When this policy is assigned, it will creates a system assigned managed identity for policy's deploy if not exist effect

- the policy assignment's system assigned managed identity will have Owner role
- the policy will only deploy the template explicit with the effect ([template](./lighthouse.policy_definition.json#L59-L60))
- the Owner role is required for Azure Lighthouse assignments ([ref](https://learn.microsoft.com/azure/lighthouse/how-to/onboard-customer#deploy-the-azure-resource-manager-template))
- the managed identity will need read permissions on the Azure Lighthouse definition

## Bicep

The bicep file is a straight decompilation from the ARM template.

```shell
az bicep decompile --file lighthouse.policy_definition.json
```
