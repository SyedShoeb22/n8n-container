provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

resource "google_compute_instance" "n8n" {
  name         = "n8n-server"
  machine_type = "e2-micro" # or t2-micro equivalent
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-22-04-lts"
      size  = 20
    }
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["n8n"]
}

output "n8n_ip" {
  value = google_compute_instance.n8n.network_interface[0].access_config[0].nat_ip
}
