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

### instances
##################################################

### db
resource "google_compute_instance_from_template" "db" {
  
  name = "db-psql"
  zone = "us-central1-a"

  source_instance_template = google_compute_instance_template.template_db.id
}