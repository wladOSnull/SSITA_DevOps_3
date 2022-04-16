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
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_admin}:${data.google_storage_bucket_object_content.key_db.content}"
  }

}