resource "google_compute_network" "peering_network" {
  name                    = "private-network-${var.env}"
  auto_create_subnetworks = "false"
}
# [END vpc_mysql_instance_private_ip_network]

# [START vpc_mysql_instance_private_ip_address]
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-addresss-${var.env}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}
# [END vpc_mysql_instance_private_ip_address]

# [START vpc_mysql_instance_private_ip_service_connection]
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
# [END vpc_mysql_instance_private_ip_service_connection]

# [START cloud_sql_mysql_instance_private_ip_instance]
resource "google_sql_database_instance" "instance" {
  name             = "private-ip-sql-instance-${var.env}"
  region           = "us-central1"
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.peering_network.id
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_private_ip_instance]

# [START cloud_sql_mysql_instance_private_ip_routes]
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.peering_network.name
  import_custom_routes = true
  export_custom_routes = true
}
