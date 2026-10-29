variable "deployment_resource_types" {
  type = list(object({
    resource_type = optional(string)
  }))
  description = "Create resource group(s) for resource type (key vault, data factory, etc...)"
  default = []
}

variable "environment" {
  type = string
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Location to deploy resources.  Defaults to eastus."
}

variable "service_principal_owners" {
  type    = set(string)
  default = []
}

variable "solution_name" {
  type = string
}

variable "subscription_id" {
  type        = string
  description = "If a new subscription is not needed, then provide the subscription id for the deployment"
}

variable "tags" {
  type = map(string)
}
