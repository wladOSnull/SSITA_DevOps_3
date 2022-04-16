### fronted for load balancer
##################################################

### forwarder
resource "google_compute_global_forwarding_rule" "server_forward" {
  name       = "server-frontend-http"
  target     = google_compute_target_http_proxy.server_proxy.self_link
  port_range = "80"
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