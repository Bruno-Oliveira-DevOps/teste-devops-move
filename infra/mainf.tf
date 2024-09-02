resource "google_compute_network" "vpc_networks" {
  count                   = length(var.network_names)
  name                    = var.network_names[count.index]
  auto_create_subnetworks = false
  project                 = var.project_id  
}

resource "google_compute_subnetwork" "subnets" {
  count          = length(var.subnet_names)
  name           = var.subnet_names[count.index]
  ip_cidr_range  = "10.${count.index}.0.0/16"
  region         = var.region
  network        = google_compute_network.vpc_networks[count.index].self_link
  project        = var.project_id  
}

resource "google_compute_router" "nat_router" {
  count    = length(var.network_names)
  name     = "nat-router-${var.network_names[count.index]}"
  network  = google_compute_network.vpc_networks[count.index].self_link
  region   = var.region
  project  = var.project_id  
}

resource "google_compute_router_nat" "nat_config" {
  count                 = length(var.network_names)
  name                  = "nat-config-${var.network_names[count.index]}"
  router                = google_compute_router.nat_router[count.index].name
  region                = var.region
  nat_ip_allocate_option = "AUTO_ONLY"
  project               = var.project_id  

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_container_cluster" "gke_clusters" {
  count      = length(var.cluster_names)
  name       = var.cluster_names[count.index]
  location   = var.region
  network    = google_compute_network.vpc_networks[count.index].self_link
  subnetwork = google_compute_subnetwork.subnets[count.index].name

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_type    = "pd-ssd"
    disk_size_gb = 50
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  remove_default_node_pool = true
  deletion_protection = false
  project = var.project_id  
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  count = length(var.cluster_names)

  name       = "primary-pool"
  cluster    = google_container_cluster.gke_clusters[count.index].name
  location   = var.region

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_type    = "pd-ssd"
    disk_size_gb = 50 
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  initial_node_count = 1
  project = var.project_id  
}

resource "google_compute_firewall" "allow_internal" {
  count = length(var.network_names)

  name    = "allow-internal-${var.network_names[count.index]}"
  network = google_compute_network.vpc_networks[count.index].name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["internal"]
  project = var.project_id  
}

resource "google_compute_firewall" "allow_ssh" {
  count = length(var.network_names)

  name    = "allow-ssh-${var.network_names[count.index]}"
  network = google_compute_network.vpc_networks[count.index].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  project = var.project_id
}

resource "google_compute_firewall" "allow_external" {
  count = length(var.network_names)

  name    = "allow-external-${var.network_names[count.index]}"
  network = google_compute_network.vpc_networks[count.index].name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  project = var.project_id  
}

resource "google_compute_firewall" "deny_all" {
  count = length(var.network_names)

  name    = "deny-all-${var.network_names[count.index]}"
  network = google_compute_network.vpc_networks[count.index].name

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  project = var.project_id  
}

resource "google_compute_network_peering" "peering1_to_peering2" {
  name         = "peering1-to-peering2"
  network      = google_compute_network.vpc_networks[0].self_link
  peer_network = google_compute_network.vpc_networks[1].self_link
}

resource "google_compute_network_peering" "peering2_to_peering1" {
  name         = "peering2-to-peering1"
  network      = google_compute_network.vpc_networks[1].self_link
  peer_network = google_compute_network.vpc_networks[0].self_link
}
