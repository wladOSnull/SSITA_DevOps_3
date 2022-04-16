locals {
    bucket = "ssita"
    prefix  = "terraform/geo_terragrunt"
    credentials = "/home/wlados/.gcp/terraform.json"

    project = "helical-history-342218"
    region  = "us-central1"
    zone    = "us-central1-a"

    root_dir = get_parent_terragrunt_dir()
}


remote_state {
    
    backend = "gcs"
    
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
        credentials = local.credentials
        bucket = local.bucket
        prefix  = local.prefix
    }
}

generate "provider" {

    path = "providers.tf"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF

provider "google" { 
    credentials = "${local.credentials}"
    project = "${local.project}"
    region  = "${local.region}"
    zone    = "${local.zone}"
}

EOF
}