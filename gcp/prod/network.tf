# VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "network-${var.env}"
  provider                = google-beta
  auto_create_subnetworks = false
}
# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "proxy-subnet${var.env}"
  provider      = google-beta
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = google_compute_network.vpc_network.id
}

# backend subnet
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "subnet-${var.env}"
  provider      = google-beta
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}


# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "forwarding-rule-${var.env}"
  provider              = google-beta
  region                = var.region
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.vpc_network.id
  subnetwork            = google_compute_subnetwork.vpc_subnet.id
  network_tier          = "PREMIUM"
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = "target-http-proxy-${var.env}"
  provider = google-beta
  region   = var.region
  url_map  = google_compute_region_url_map.default.id
}

# URL map
resource "google_compute_region_url_map" "default" {
  name            = "regional-url-map-${var.env}"
  provider        = google-beta
  region          = var.region
  default_service = google_compute_region_backend_service.default.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "backend-subnet-${var.env}"
  provider              = google-beta
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# MIG
resource "google_compute_region_instance_group_manager" "mig" {
  name     = "mig1-${var.env}"
  provider = google-beta
  region   = var.region
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

# allow all access from IAP and health check ranges
resource "google_compute_firewall" "fw-iap" {
  name          = "fw-allow-iap-hc-${var.env}"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20", "179.125.19.0/24"]
  allow {
    protocol = "tcp"
  }
}


# health check
resource "google_compute_region_health_check" "default" {
  name     = "hc-${var.env}"
  provider = google-beta
  region   = var.region
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}
#creation of a firewall with ssh and http enable
# Cria o Firewall para a VM
resource "google_compute_firewall" "allow-http-ssh" {
  name        = "${var.env}"
  network     = google_compute_network.vpc_network.id
  target_tags   = ["allow-http-ssh"]
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20", "179.0.0.0/8"]
  allow {
    protocol  = "tcp"
    ports     = "${var.portas}"
  }
}

#make a public address with static ip for connection with ssh
resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project
  region     = var.region
  depends_on = [google_compute_firewall.allow-http-ssh]
}

resource "google_compute_instance_template" "instance_template" {
  name         = "mig-template-${var.env}"
  provider     = google-beta
  machine_type = "f1-micro"
  tags         = google_compute_firewall.allow-http-ssh.target_tags


  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id
    access_config {
        nat_ip = google_compute_address.static.address
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }


  lifecycle {
    create_before_destroy = true
  }
}

#mysql cofiguration
#module "mysql" {
#  source = "../modules/mysql"
#  env = var.env
#}