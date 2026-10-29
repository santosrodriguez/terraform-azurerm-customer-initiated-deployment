output "subscription_name" {
  description = "Display name of the target subscription."
  value       = data.azurerm_subscription.sub.display_name
}

output "resource_group_names" {
  description = "Map of created resource group names."
  value = {
    for k, rg in azurerm_resource_group.deployment_rgs : k => rg.name
  }
}

output "resource_group_ids" {
  description = "Map of created resource group IDs."
  value = {
    for k, rg in azurerm_resource_group.deployment_rgs : k => rg.id
  }
}

output "entra_group_name" {
  description = "Display name of the Entra ID security group created for this deployment."
  value       = azuread_group.group.display_name
}

output "entra_group_object_id" {
  description = "Object ID of the Entra ID security group created for this deployment."
  value       = azuread_group.group.object_id
}

output "service_principal_name" {
  description = "Display name of the Azure AD application / service principal."
  value       = azuread_application.app.display_name
}

output "application_client_id" {
  description = "Client ID of the Azure AD application."
  value       = azuread_application.app.client_id
}

output "application_object_id" {
  description = "Object ID of the Azure AD application."
  value       = azuread_application.app.object_id
}

output "service_principal_object_id" {
  description = "Object ID of the Azure AD service principal."
  value       = azuread_service_principal.sp.object_id
}

output "service_principal_client_id" {
  description = "Client ID of the Azure AD service principal."
  value       = azuread_service_principal.sp.client_id
}

output "random_suffix" {
  description = "Random suffix used in resource naming."
  value       = random_string.suffix.result
}
