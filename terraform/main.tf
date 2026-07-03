terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  description = "Resource group that contains your existing VM and NSG"
  type        = string
}

variable "nsg_name" {
  description = "Name of the existing Network Security Group attached to your VM"
  type        = string
}

variable "app_port" {
  description = "Port your app is exposed on (80, since docker maps container:8000 -> host:80)"
  type        = number
  default     = 80
}

variable "allowed_source" {
  description = "CIDR allowed to reach the app. Use 0.0.0.0/0 for public access."
  type        = string
  default     = "0.0.0.0/0"
}
