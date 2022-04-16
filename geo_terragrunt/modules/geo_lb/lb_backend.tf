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

### server group (backend)
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
    initial_delay_sec = 420
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
    cooldown_period = 420

    cpu_utilization {
      target = 0.75
    }
  }

}