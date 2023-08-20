locals {
  azure_environments = {
    dev_uk_south = {
      subscription = ""

      region           = "UK South"
      environment-name = "uks-prod"

      key-vault-name = "dev-env"
      tenant-id      = ""

      root_public_key = ""

      network = {
        cidr = "10.130.48.0/20"

        # There must be 4 subnets!
        # First: AKS
        # Second: Compute/VMs/Classic LBs
        # Third: Application Gateway
        # Fourth: VPN, Always named: GatewaySubnet
        # ... Azure is stupid
        subnets_address_space = ["10.130.48.0/21", "10.130.56.0/23", "10.130.58.0/24", "10.130.59.0/24"]
        subnets_names         = ["uks-dev-subnet1-aks", "uks-dev-subnet2-compute", "uks-dev-subnet2-app-gateway", "GatewaySubnet"]

        subnet_enforce_private_link_endpoint_network_policies = {
          "uks-dev-subnet1-aks" = true
        }
      }

      test = {
        dns-zone-name = "test.com"
      }

      application-gateway = {
        ssl-certs-hostnames = {
          "uks-dev-test-com" = ["test.com", "*.test.com"]         
        }
      }
    }
  }
}
