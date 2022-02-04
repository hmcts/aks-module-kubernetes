resource "azurerm_public_ip" "sds-public-ip" {
  count = var.environment == "demo" ? 1 : 0
  name                = "${var.project}-${var.environment}-${var.cluster_number}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  tags = var.tags
}