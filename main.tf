terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# Azure Objects
data "azurerm_subscription" "sub" {
  subscription_id = var.subscription_id
}

data "azuread_users" "sp_owners" {
  user_principal_names = var.service_principal_owners
}

locals {
  subscription_name      = data.azurerm_subscription.sub.display_name
  entra_group_name       = "AzureAdmin${upper(var.environment)}_${lower(var.solution_name)}_${upper(local.subscription_name)}_rg-${lower(var.solution_name)}"
  service_principal_name = "SP_Terraform_${lower(var.solution_name)}_${upper(local.subscription_name)}_${lower(var.solution_name)}"
  rg_deployment_cnt      = length(var.deployment_resource_types)
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  lower = false
  numeric = true
}

resource "azurecaf_name" "rg_names" {
  for_each      = local.rg_deployment_cnt == 0 ? tomap({ "1" = { resource_type = var.solution_name } }) : tomap(var.deployment_resource_types)
  resource_type = "azurerm_resource_group"
  suffixes      = local.rg_deployment_cnt == 0 ? [each.value.resource_type, var.location, lower(var.environment), random_string.suffix.result] : [var.solution_name, replace(each.value.resource_type, " ", ""), var.location, lower(var.environment), random_string.suffix.result]
}

resource "azurerm_resource_group" "deployment_rgs" {
  for_each = { for k, v in azurecaf_name.rg_names : k => v }
  location = var.location
  name     = each.value.result
  tags     = var.tags
}

# Entra resources
resource "azuread_group" "group" {
  display_name     = local.entra_group_name
  security_enabled = true
  mail_enabled     = false
}

resource "azuread_application" "app" {
  display_name = local.service_principal_name
  owners       = data.azuread_users.sp_owners.object_ids
}

resource "azuread_service_principal" "sp" {
  client_id = azuread_application.app.client_id
  owners    = data.azuread_users.sp_owners.object_ids
}

# Permission Assignment

resource "azurerm_role_assignment" "sp_infra" {
  principal_id         = azuread_service_principal.sp.object_id
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/Infrastructure_RG"
  role_definition_name = "CS - Terraform SP VNET Private Endpoint Contributor"
}

resource "azurerm_role_assignment" "sp_resources" {
  for_each             = { for k, v in azurerm_resource_group.deployment_rgs : k => v }
  principal_id         = azuread_service_principal.sp.object_id
  role_definition_name = "Contributor"
  scope                = each.value.id
}

resource "azurerm_role_assignment" "ad_grp_resources" {
  for_each             = { for k, v in azurerm_resource_group.deployment_rgs : k => v }
  principal_id         = azuread_group.group.object_id
  role_definition_name = "Contributor"
  scope                = each.value.id
}

# Add SP to Terraform Shared Resource access to be able to correctly deploy private endpoints
resource "azuread_group_member" "sp_group" {
  group_object_id  = "eaa11ac7-da45-4093-a5bc-9ca951879f5e"
  member_object_id = azuread_service_principal.sp.object_id
}
