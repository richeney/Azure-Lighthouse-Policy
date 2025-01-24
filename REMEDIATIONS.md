# Remediations

Follow the documentation for viewing non-compliant resource and creating remediation tasks in the portal. Remember is that compliancy reports can be viewed at all scopes, but remediation jobs should be viewed at the scope of the resources being remediated. In this case, use the subscription scopes, not the management group used for the policy assignment.

## Triggering a scan

Policy scans are triggered automatically within 30 minutes of assignments, and then daily. You may manually also trigger a scan.

1. Trigger an Azure Policy scan for a subscription scope

    ```shell
    az policy state trigger-scan --no-wait --subscription subscription_id
    ```

    Replace subscription_id with the subscription GUID.

## Manually remediate via the CLI

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
