resource "azurerm_public_ip" "aks_public_lb" {
  name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-aks-public-ip"

  resource_group_name = azurerm_resource_group.root.name
  location            = azurerm_resource_group.root.location

  domain_name_label = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-test-public-appgw"

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}

resource "azurerm_application_gateway" "aks_public_lb" {
  name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-aks-public-lb"

  resource_group_name = azurerm_resource_group.root.name
  location            = azurerm_resource_group.root.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-ip-conf"
    subnet_id = module.network.vnet_subnets[2]
  }

  frontend_port {
    name = local.application_gateway.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.application_gateway.frontend_port_name_https
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.application_gateway.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.aks_public_lb.id
  }

  backend_address_pool {
    name = local.application_gateway.backend_address_pool_name
  }

  probe {
    name = local.application_gateway.probe_name

    host            = "127.0.0.1"
    interval        = 30
    minimum_servers = 0

    path                                      = "/healthz"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"

    timeout             = 5
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
      body        = ""
    }
  }

  probe {
    name = local.application_gateway.probe_name_https

    host            = "127.0.0.1"
    interval        = 30
    minimum_servers = 0

    path                                      = "/healthz"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"

    timeout             = 5
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
      body        = ""
    }
  }

waf_configuration {
    enabled                  = true
    file_upload_limit_mb     = 100
    firewall_mode            = "Prevention"
    max_request_body_size_kb = 128
    request_body_check       = true
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"

  }

  backend_http_settings {
    name = local.application_gateway.backend_http_setting_name

    cookie_based_affinity = "Disabled"
    port                  = 32080
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = local.application_gateway.probe_name
  }

  backend_http_settings {
    name = local.application_gateway.backend_https_setting_name

    cookie_based_affinity = "Disabled"
    port                  = 32080
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = local.application_gateway.probe_name_https
  }

  ssl_policy {
    policy_type          = "Custom"
    cipher_suites        = ["TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"]
    min_protocol_version = "TLSv1_2"
  }

  http_listener {
    name = local.application_gateway.listener_name_http

    frontend_ip_configuration_name = local.application_gateway.frontend_ip_configuration_name
    frontend_port_name             = local.application_gateway.frontend_port_name_http
    protocol                       = "Http"
  }

  dynamic "http_listener" {
    for_each = module.dev_envs.azure_environments[terraform.workspace]["application-gateway"]["ssl-certs-hostnames"]

    content {
      name = "${http_listener.key}-https-listener"

      frontend_ip_configuration_name = local.application_gateway.frontend_ip_configuration_name
      frontend_port_name             = local.application_gateway.frontend_port_name_https
      protocol                       = "Https"
      require_sni                    = true

      ssl_certificate_name = "${http_listener.key}-ssl-cert"
      host_names           = http_listener.value
    }
  }

  request_routing_rule {
    name = "http-backend-routing-rule"

    rule_type = "Basic"

    http_listener_name         = local.application_gateway.listener_name_http
    backend_address_pool_name  = local.application_gateway.backend_address_pool_name
    backend_http_settings_name = local.application_gateway.backend_http_setting_name
  }

  dynamic "request_routing_rule" {
    for_each = module.dev_envs.azure_environments[terraform.workspace]["application-gateway"]["ssl-certs-hostnames"]

    content {
      name = "${request_routing_rule.key}-backend-routing-rule"

      rule_type = "Basic"

      http_listener_name         = "${request_routing_rule.key}-https-listener"
      backend_address_pool_name  = local.application_gateway.backend_address_pool_name
      backend_http_settings_name = local.application_gateway.backend_https_setting_name
    }
  }

  dynamic "ssl_certificate" {
    for_each = module.dev_envs.azure_environments[terraform.workspace]["application-gateway"]["ssl-certs-hostnames"]

    content {
      name                = "${ssl_certificate.key}-ssl-cert"
      key_vault_secret_id = data.azurerm_key_vault_certificate.app_gateway_certs[ssl_certificate.key].secret_id
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_public_lb.id]
  }

  tags = local.common_tags
}

resource "azurerm_user_assigned_identity" "aks_public_lb" {
  name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-aks-public-lb-uai"

  resource_group_name = azurerm_resource_group.root.name
  location            = azurerm_resource_group.root.location

  tags = local.common_tags
}

resource "azurerm_key_vault_access_policy" "aks_public_lb" {
  key_vault_id = data.azurerm_key_vault.root.id

  tenant_id = module.dev_envs.azure_environments[terraform.workspace]["tenant-id"]
  object_id = azurerm_user_assigned_identity.aks_public_lb.principal_id

  secret_permissions = [
    "get"
  ]
}
