output "policy_definition_id" {
  value = azurerm_policy_definition.assign_azure_lighthouse.id
}

output "management_group_resource_id" {
  value = local.management_group_resource_id
}

output "management_group_id" {
  value = try(basename(local.management_group_resource_id), null)
}