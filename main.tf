data "azurerm_resource_group" "rgname" {
name = var.rgname
}
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  address_space       = var.vnet_cidr
  location = data.azurerm_resource_group.rgname.location
  resource_group_name = data.azurerm_resource_group.rgname.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = data.azurerm_resource_group.rgname.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_cidr
  
}
// nsg...
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = data.azurerm_resource_group.rgname.location
  resource_group_name = data.azurerm_resource_group.rgname.name

  security_rule {
    name                       = var.nsg_rule_name
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.tag
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
#create public ip address
resource "azurerm_public_ip" "public" {
  name                    = "${var.vmname}-PIP"
  location                = data.azurerm_resource_group.rgname.location
  resource_group_name     = data.azurerm_resource_group.rgname.name
  allocation_method       = "Dynamic"
  
}
#create Network interface 
resource "azurerm_network_interface" "Inc" {
  name                = "${var.vmname}-Nic"
  location            = data.azurerm_resource_group.rgname.location
  resource_group_name = data.azurerm_resource_group.rgname.name

  ip_configuration {
    name                          = "${var.vmname}-IP"
    subnet_id                     = azurerm_subnet.subnet.id
    //private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.dc_ips
  }
}
# create the  Vm machine 
resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vmname
  resource_group_name = data.azurerm_resource_group.rgname.name
  location            = data.azurerm_resource_group.rgname.location
  size                = "Standard_DS1_v2"
  admin_username      = "vmadmin"
  admin_password      = "Welcome@1234"
  //patch_mode = "Manual"
  network_interface_ids = [
    azurerm_network_interface.Inc.id,
  ]
# Disk type define here
  os_disk {
    name = "${var.vmname}-OS-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
# os Source 
 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}