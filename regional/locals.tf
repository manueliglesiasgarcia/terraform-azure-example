locals {
  common_tags = {
    environment    = module.dev_envs.azure_environments[terraform.workspace]["environment-name"]
    owner          = "devops"
    team           = "devops"
    project        = "test"
  }

  application_gateway = {
    backend_address_pool_name      = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-backend-pool"
    frontend_port_name_http        = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-frontend-http"
    frontend_port_name_https       = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-frontend-https"
    frontend_ip_configuration_name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-frontend-ip-conf"

    backend_http_setting_name  = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-backend-settings"
    backend_https_setting_name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-backend-settings-https"

    listener_name_http = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-listener-http"

    redirect_configuration_name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-rdrcfg"

    probe_name       = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-probe"
    probe_name_https = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-probe-https"

    redirect_rule_name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-appwg-rdrct"
  }


}
