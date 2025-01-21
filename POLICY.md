# Azure Lighthouse policy definition

Example Azure Policy for automated delegation.

- Takes a single parameter for the definition resource ID
- New subscriptions created under the management group are automatically delegated
- Deploy if Not Exists effect supports remediation of non-compliant subscription scopes
- Policy assignments can exclude areas e.g. assign at Azure Landing Zone and exclude Decommissioned and Sandpit scopes

The example commands assume you are creating the policy definition at the management group es.

Note that the system assigned managed identity will have Owner for the template deployment as this is required for Azure Lighthouse assignments.

The managed identuty will need to have

## ARM

```shell
az deployment mg create --management-group-id es --name lighthouse --location uksouth --template-file assignment_policy.json --parameters @assignment_policy.standard.parameters.json
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
    az policy remediation list --resource /subscriptions/$data
    ```

    You can also view remediations in the portal. Navigate to the subscription or resource. Click on Policy and then Remediations and they can be found on the second tab. This is useful for troubleshooting.

1. View a specific remediation

    ```shell
    az policy remediation show --name "myRemediation"
    ```

    If the remediation is running successfully then it should deploy the template. You can see this in the portal by navigating to the subscription and clicking on Deployments.
