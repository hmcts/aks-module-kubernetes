resource "azurerm_public_ip" "example" {
  count = var.environment == "demo" ? 1 : 0
  name                = "${var.project}-${var.environment}-public-ip-${var.cluster_number}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  tags = var.tags
}