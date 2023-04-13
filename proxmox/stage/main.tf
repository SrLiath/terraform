terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    tls = {
      source  = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
provider "proxmox" {
  pm_api_url          = "https://<your proxmox server>:8006/api2/json"
  pm_api_token_id     = "<your pve user>"
  pm_api_token_secret = "<your secret for the pve user>"
  pm_tls_insecure     = true
  pm_debug            = true
}

module "virtual_machine" {
  source = "../modules/vm"
  virtual_machines = local.machines
}