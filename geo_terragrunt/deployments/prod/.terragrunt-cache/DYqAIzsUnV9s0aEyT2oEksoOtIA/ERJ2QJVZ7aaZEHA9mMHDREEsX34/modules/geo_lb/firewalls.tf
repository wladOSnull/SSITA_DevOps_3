### firewalls
##################################################

### server
resource "google_compute_firewall" "firewall_server" {
	
  target_tags   = ["tag-server"]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  name    = "template-server-tomcat"
	network = "default"

  allow {
      protocol = "tcp"
      ports    = ["8080", "80"]
  }
}

### db
resource "google_compute_firewall" "firewall_db" {
	
  target_tags = ["tag-db"]
  direction   = "INGRESS"
  source_tags = ["tag-server"]

  name    = "template-db-psql"
	network = "default"

  allow {
      protocol = "tcp"
      ports    = ["5432"]
  }
}

### common
resource "google_compute_firewall" "firewall_server_db" {

  target_tags   = ["tag-server", "tag-db"]
  direction     = "INGRESS"
  source_ranges = var.ssh_ip

  name    = "template-ssh"
	network = "default"

	allow {
		protocol = "tcp"
		ports    = ["22"]
	}
}