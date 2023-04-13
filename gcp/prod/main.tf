provider "google" {
  project     = var.project
  region      = var.region
  credentials = file(var.key)
  zone        = "${var.region}-a"

}
provider "google-beta" {
  project     = var.project
  region      = var.region
  credentials = file(var.key)
  zone        = "${var.region}-a"

}


#creation of a virtual machine
resource "google_compute_instance" "prod_instance" {
  name         = var.env
  machine_type = "f1-micro"
  tags         = google_compute_firewall.allow-http-ssh.target_tags

  metadata = {
    ssh-keys = "${var.userssh}:${file(var.publickey)}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  #network data
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  
   metadata_startup_script = "sudo apt-get update; sudo apt-get install apache2 -y; echo Testando > /var/www/html/index.html"

  #ssh connection to install docker
  #provisioner "remote-exec" {
  #  connection {
  #    type        = "ssh"
  #    user        = var.userssh
  #    private_key = file(var.privatekey)
  #    host        = google_compute_instance.prod_instance.network_interface[0].access_config[0].nat_ip
#
  #  }
  #  inline = [
  #    "curl -fsSL https://get.docker.com -o get-docker.sh",
  #    "sh get-docker.sh",
  #    "sudo docker pull debian",
  #    "sudo docker run -t -d --name debian debian",
  #    "sudo docker exec -it debian apt-get update",
  #    "sudo apt-get update",
  #    "sudo docker exec -it debian apt-get install apache2 -y",
  #  ]
  #}
}





