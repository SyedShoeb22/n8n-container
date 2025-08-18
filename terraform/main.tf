terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  credentials = file(var.credentials_file)
}

resource "google_compute_instance" "n8n_vm" {
  name         = "n8n-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20240606"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose
    sudo usermod -aG docker $USER
    mkdir -p /opt/n8n
    cd /opt/n8n
    cat <<EOF > docker-compose.yml
    version: "3"
    services:
      n8n:
        image: n8nio/n8n:latest
        ports:
          - "5678:5678"
        restart: always
        environment:
          - N8N_BASIC_AUTH_ACTIVE=true
          - N8N_BASIC_AUTH_USER=admin
          - N8N_BASIC_AUTH_PASSWORD=secret
          - N8N_SECURE_COOKIE=false
    EOF
    sudo docker-compose up -d
  EOT
}
