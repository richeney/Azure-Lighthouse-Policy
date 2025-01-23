# Azure Lighthouse policy definition

Azure Policy designed for management group assignment. The policy will automatically assign an Azure Lighthouse definition to new subscriptions using a _deploy if not exists_ policy effect.

- The policy is defined with no parameters
- Specify a single parameter for the definition resource ID when assigning
- New subscriptions created under the management group are automatically delegated
- Policy assignments can exclude areas
  - e.g. assign at Azure Landing Zone and exclude Decommissioned and Sandpit scopes
- The _deploy if not exists effect_ supports remediation of non-compliant subscriptions

The example commands assume you are creating the policy definition at the management group es.

Notes

- the policy assignment's system assigned managed identity will have Owner role
- the Owner role is required for Azure Lighthouse assignments
- the managed identity will need read permissions on the Azure Lighthouse definition

The bicep file is a straight decompilation from the ARM template using:

```shell
az bicep decompile --file lighthouse.policy_definition.json
```

## Examples

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

### Terraform module

```ruby
module "lighthouse_policy" {
  source              = "github.com/richeney/lighthouse_policy?ref=v0.1"
  management_group_id = "es"
}
```

## Additional commands

### Trigger a scan

Policy scans are triggered automatically within 30 minutes of assignments, and then daily. Or you can manually trigger a scan.

1. Trigger an Azure Policy scan for a subscription scope

    ```shell
    az policy state trigger-scan --no-wait --subscription subscription_id
    ```

    Replace subscription_id with the subscription GUID.

### Manually remediate via the CLI

1. Set a variable for the policy assignment ID

    Copy and paste the assignment ID from the Azure Policy pages in the Azure Portal, e.g.

    ```shell
    policyDefinitionId="/providers/Microsoft.Management/managementGroups/es/providers/Microsoft.Authorization/policyAssignments/d0f40be55d314f42807a301d"
    ```

    or via Azure CLI commands, e.g.

    ```shell
    mg="/providers/Microsoft.Management/managementGroups/es"
    policyDefinitionId="${mg}/providers/Microsoft.Authorization/policyDefinitions/Assign-Azure-Lighthouse"
    policyAssigmentId=$(az policy assignment list --scope $mg --query "[?policyDefinitionId == '"$policyDefinitionId"'].id" -otsv)
    ```

1. Set the scope

    ```shell
    scope=/subscriptions/subscription_id
    ```

    Replace subscription_id with the subscription GUID.

1. Create a remediation task

    ```shell
    az policy remediation create --name "myRemediation" --policy-assignment $policyAssignmentId --resource $scope
    ```

    Change name for the remediation to keep it unique.

1. View the remediations for a resource

    ```shell
    az policy remediation list --resource $scope
    ```

    You can also view remediations in the portal. Navigate to the subscription or resource. Click on Policy and then Remediations and they can be found on the second tab. This is useful for troubleshooting.

1. View a specific remediation

    ```shell
    az policy remediation show --name "myRemediation"
    ```

    If the remediation is running successfully then it should deploy the template. You can see this in the portal by navigating to the subscription and clicking on Deployments.
