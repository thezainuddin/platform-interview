terraform {
  required_version = ">= 1.0.7"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }

    vault = {
      version = "3.0.1"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}


resource "vault_audit" "audit" {
  provider = vault
  type     = "file"

  options = {
    file_path = "/vault/logs/audit"
  }
}

resource "vault_auth_backend" "userpass" {
  provider = vault
  type     = "userpass"
}

resource "vault_generic_secret" "account" {
  provider = vault
  path     = "secret/${var.env}/account"

  data_json = <<EOT
{
  "db_user":   "account",
  "db_password": "${var.account_db_pw}"
}
EOT
}

resource "vault_policy" "account" {
  provider = vault
  name     = "account-${var.env}"

  policy = <<EOT

path "secret/data/${var.env}/account" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "account" {
  provider             = vault
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/account-${var.env}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["account-${var.env}"],
  "password": "123-account-${var.env}"
}
EOT
}

resource "vault_generic_secret" "gateway" {
  provider = vault
  path     = "secret/${var.env}/gateway"

  data_json = <<EOT
{
  "db_user":   "gateway",
  "db_password": "${var.gateway_db_pw}"
}
EOT
}

resource "vault_policy" "gateway" {
  provider = vault
  name     = "gateway-${var.env}"

  policy = <<EOT

path "secret/data/${var.env}/gateway" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "gateway" {
  provider             = vault
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/gateway-${var.env}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["gateway-${var.env}"],
  "password": "123-gateway-${var.env}"
}
EOT
}
resource "vault_generic_secret" "payment" {
  provider = vault
  path     = "secret/${var.env}/payment"

  data_json = <<EOT
{
  "db_user":   "payment",
  "db_password": "${var.payment_db_pw}"
}
EOT
}

resource "vault_policy" "payment" {
  provider = vault
  name     = "payment-${var.env}"

  policy = <<EOT

path "secret/data/${var.env}/payment" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "payment" {
  provider             = vault
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/payment-${var.env}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["payment-${var.env}"],
  "password": "123-payment-${var.env}"
}
EOT
}

##############################################

resource "docker_container" "account" {
  image = "form3tech-oss/platformtest-account"
  name  = "account_${var.env}"

  env = [
    "VAULT_ADDR=http://vault-${var.env}:8200",
    "VAULT_USERNAME=account-${var.env}",
    "VAULT_PASSWORD=123-account-${var.env}",
    "ENVIRONMENT=${var.env}"
  ]

  networks_advanced {
    name = "vagrant_${var.env}"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "payment" {
  image = "form3tech-oss/platformtest-payment"
  name  = "payment_${var.env}"

  env = [
    "VAULT_ADDR=http://vault-${var.env}:8200",
    "VAULT_USERNAME=payment-${var.env}",
    "VAULT_PASSWORD=123-payment-${var.env}",
    "ENVIRONMENT=${var.env}"
  ]

  networks_advanced {
    name = "vagrant_${var.env}"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "gateway" {
  image = "form3tech-oss/platformtest-gateway"
  name  = "gateway_${var.env}"

  env = [
    "VAULT_ADDR=http://vault-${var.env}:8200",
    "VAULT_USERNAME=gateway-${var.env}",
    "VAULT_PASSWORD=123-gateway-${var.env}",
    "ENVIRONMENT=${var.env}"
  ]

  networks_advanced {
    name = "vagrant_${var.env}"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "frontend" {
  image = var.nginx_img
  name  = "frontend_${var.env}"

  ports {
    internal = 80
    external = var.nginx_port
  }

  networks_advanced {
    name = "vagrant_${var.env}"
  }

  lifecycle {
    ignore_changes = all
  }
}
