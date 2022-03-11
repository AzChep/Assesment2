terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}
provider "azurerm" {
  features {}
  subscription_id           = var.subscription_id
  tenant_id                 = var.subscription_tenant_id
}
resource "azurerm_resource_group" "rg" {                                                    //RG
  name     = var.resource_group_name
  location = "westeurope"

   tags = {
     Environment = "Assesment tehtävä 1"
     Team = "Saakura Consulting"
   }
}
resource "azurerm_virtual_network" "terraform-checkpoint7-vnet" {                         //Virtual network
    name                = "Ville-checkpoint7-vnet"
    address_space       = ["10.0.0.0/24"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "scubnet" {                                                      //Scubanet
  name                 = "Ville-checkpoint7-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.terraform-checkpoint7-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "terraform-checkpoint7-NSG" {      //NSG
    name                = "terraform-checkpoint7-NSG"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Assesment tehtävä 1"
        Team = "Saakura Consulting"
    }
}
resource   "azurerm_network_interface"   "CP7-NIC"   {                //network interface card 
  name   =   "Ville-Checkpoint7-NIC" 
  location   =   "westeurope" 
  resource_group_name   =   azurerm_resource_group.rg.name 

  ip_configuration   { 
    name   =   "AssesmentConfig" 
    subnet_id   =   azurerm_subnet.scubnet.id 
    private_ip_address_allocation   =   "Dynamic" 
  } 
}

resource "azurerm_linux_virtual_machine" "AVM" {                      //LinuxVm
    name                  = "Ville-checkpoint7-VM"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.CP7-NIC.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "debian"
        offer     = "debian-11"
        sku       = "11-gen2"
        version   = "latest"
    }
    computer_name  = "AssesmentVM"
    admin_username = var.administrator_login
    admin_password = var.administrator_login_password
    disable_password_authentication = false

    tags = {
        environment = "Assesment tehtävä 1"
        Team = "Saakura Consulting"
    }
  }