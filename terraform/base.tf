### main
##################################################

### remote backend
terraform {

    backend "gcs" {

    credentials = "/home/wlados/.gcp/terraform.json"
    
    bucket  = "ssita"
    prefix  = "terraform/terraform_base.tfstate"
    }
}

### account
provider "google" {

    credentials = "/home/wlados/.gcp/terraform.json"

    project = "helical-history-342218"
    region  = "us-central1"
    zone    = "us-central1-a"
}

### disks
##################################################

### backup 
resource "google_compute_resource_policy" "daily_backup" {
  name   = "every-day-4am"
  region = "us-central1"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
  }
}

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

### templates
##################################################

### server
resource "google_compute_instance_template" "template_server" {
  name        = "template-server"
  description = "This template is used to create Geo Citizen server instances."

  tags = ["tag-server"]

  labels = {
    instance_type = "server"
  }

  instance_description = "Geo Citizen server"
  machine_type         = "g1-small"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image      = "ubuntu-2004-focal-v20220204"
    auto_delete       = true
    boot              = true
    disk_size_gb      = 10
    disk_type         = "pd-ssd"
    resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_admin}:${data.google_storage_bucket_object_content.key_server.content}"

    startup-script = <<SCRIPT
apt update
apt install -y apache2
echo "hostname ---> $HOSTNAME" > /var/www/html/index.html

sudo apt install -y curl
EXTERNAL_IP(){
    curl ifconfig.me
}
curl -X POST -H "Content-Type: application/json" -d "{'host': $(EXTERNAL_IP), 'label': $(hostname)}" https://p7muwk4sqzmsoty28nz3mr.hooks.webhookrelay.com/invoke?token=geoserver
      SCRIPT
  }
 
}

### db
resource "google_compute_instance_template" "template_db" {
  name        = "template-db"
  description = "This template is used to create Geo Citizen DB instances."

  tags = ["tag-db"]

  labels = {
    instance_type = "db"
  }

  instance_description = "Geo Citizen DB"
  machine_type         = "g1-small"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image      = "centos-7-v20220126"
    auto_delete       = true
    boot              = true
    disk_size_gb      = 20
    disk_type         = "pd-ssd"
#    resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_admin}:${data.google_storage_bucket_object_content.key_db.content}"

    startup-script = <<SCRIPT
yum update -y
yum install -y git
git clone https://github.com/KittyKatt/screenFetch screenfetch
cp screenfetch/screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
      SCRIPT    
  }

}

### instances
##################################################

### db
resource "google_compute_instance_from_template" "db" {
  
  name = "db-psql"
  zone = "us-central1-a"

  source_instance_template = google_compute_instance_template.template_db.id
}

### instance groups stuff
##################################################

### health checker
resource "google_compute_health_check" "health_8080" {
  name        = "health-check-8080"
  description = "Health check via tcp"

  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = "8080"
  }
}

### server group
resource "google_compute_instance_group_manager" "server_group" {
  
  name = "group-servers"
  zone = "us-central1-a"

  base_instance_name = "server"

  version {
    instance_template  = google_compute_instance_template.template_server.id
  }

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.health_8080.id
    initial_delay_sec = 300
  }
}

### autoscaler
resource "google_compute_autoscaler" "autoscaler_servers" {

  name   = "autoscaler-for-servers"
  zone   = "us-central1-a"
  target = google_compute_instance_group_manager.server_group.id

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 300

    cpu_utilization {
      target = 0.75
    }
  }

}

### fronted for load balancer
##################################################

### forwarder
resource "google_compute_global_forwarding_rule" "server_forward" {
  name       = "server-frontend-http"
  target     = google_compute_target_http_proxy.server_proxy.self_link
  port_range = "8080"
}

### HTTP target proxy
resource "google_compute_target_http_proxy" "server_proxy" {
  name        = "server-proxy"
  url_map     = google_compute_url_map.server_map.self_link
}

### URL map
resource "google_compute_url_map" "server_map" {
  name            = "server-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.health_8080.id]

  backend {
    group = google_compute_instance_group_manager.server_group.instance_group
  }
}