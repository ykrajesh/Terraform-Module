terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.59.0"
    }
  }
}
provider "azurerm" {
  features {
    
  }
}

module "vnet" {
    source = "../" //provode the mocule path 
    rgname = "learn-ab33a287-6055-420e-882e-2ae8b8c6ee2b"
    tag = "prod"
    vnetname = "prodvnet"
    vnet_cidr = ["10.0.0.0/16"]
    subnet = "eastus-prod"
    subnet_cidr = ["10.0.1.0/24"]
    nsg_name = "prod-nsg"
    nsg_rule_name = "test-server"
    vmname ="Testvm"
    dc_ips = "10.0.1.5"

}